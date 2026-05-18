module Demo
  class SafetyController < Demo::ApplicationController
    before_action :require_demo_mode
    before_action :require_safety_session, only: [ :chats, :audit_events, :flag_conversation ]

    # POST /demo/safety/request_code
    def request_code
      dev_password = ENV["SAFETY_DEV_PASSWORD"].presence || "safety-dev"

      if params[:password] == dev_password
        verified_at = Time.current
        session[:safety_verified_at] = verified_at.iso8601
        session[:safety_user_id]     = current_user.id

        safety_token = JWT.encode(
          { sub: current_user.id, safety: true, iat: verified_at.to_i, exp: 4.hours.from_now.to_i },
          Rails.application.secret_key_base,
          "HS256"
        )

        log_activity(:safety_accessed, {
          ip:           request.remote_ip,
          accessor_role: accessor_role_label,
          dev_bypass:   true
        })

        notify_supervisors_of_access

        return render json: { sent: false, dev_bypass: true, safety_token: safety_token }
      end

      render json: { error: "Invalid password" }, status: :unauthorized
    end

    # POST /demo/safety/verify
    def verify
      render json: { error: "Use the dev password bypass" }, status: :unprocessable_entity
    end

    # POST /demo/safety/end_session
    def end_session
      duration = nil

      if session[:safety_verified_at]
        duration = (Time.current - Time.parse(session[:safety_verified_at])).round
        session.delete(:safety_verified_at)
        session.delete(:safety_user_id)
      elsif (token = request.headers["X-Safety-Token"].presence)
        begin
          payload = JWT.decode(token, Rails.application.secret_key_base, true, algorithms: [ "HS256" ])[0]
          duration = (Time.current - Time.at(payload["iat"])).round if payload["safety"]
        rescue JWT::DecodeError, JWT::ExpiredSignature
          nil
        end
      end

      return render json: { ended: false } unless duration

      log_activity(:safety_exited, {
        reason:           params[:reason],
        duration_seconds: duration,
        accessor_role:    accessor_role_label
      })

      render json: { ended: true, duration_seconds: duration }
    end

    # GET /demo/safety/chats
    def chats
      names = Array(params[:student_names]).map(&:strip).reject(&:blank?)
      from  = parse_date(params[:from]) || 30.days.ago.to_date
      to    = parse_date(params[:to])   || Date.current
      keyword = params[:keyword].presence

      return render json: { error: "At least one name is required" }, status: :unprocessable_entity if names.empty?

      members = find_members(names)

      if members.empty?
        log_activity(:chat_searched, {
          student_names: names,
          from:          from.to_s,
          to:            to.to_s,
          keyword:       keyword,
          found_count:   0,
          notes:         "Searched: #{names.join(', ')} | #{from}–#{to}#{keyword ? " | keyword: \"#{keyword}\"" : ''} | 0 messages found",
          accessor_role: accessor_role_label
        })
        return render json: { results: [], members_not_found: names, searched_from: from, searched_to: to, keyword:, total_messages: 0 }
      end

      results = build_results(members, from, to, keyword).reject { |r| r[:channels].empty? }
      total   = results.sum { |r| r[:channels].sum { |c| c[:messages].length } }

      log_activity(:chat_searched, {
        student_names: names,
        from:          from.to_s,
        to:            to.to_s,
        keyword:       keyword,
        found_count:   total,
        notes:         "Searched: #{names.join(', ')} | #{from}–#{to}#{keyword ? " | keyword: \"#{keyword}\"" : ''} | #{total} message#{'s' unless total == 1} found",
        accessor_role: accessor_role_label
      })

      notify_supervisors(names, "searched: #{names.join(', ')} | #{from}–#{to}#{keyword ? " | keyword: \"#{keyword}\"" : ''} | #{total} message#{'s' unless total == 1} found")

      render json: { results:, searched_from: from, searched_to: to, keyword:, total_messages: total }
    end

    # GET /demo/safety/audit_events
    def audit_events
      ad_roles = %w[athletic_director school_admin district_admin super_admin]
      unless ad_roles.include?(accessor_role_label)
        return render json: { error: "Not authorized" }, status: :forbidden
      end

      events = Activity
        .where(event_type: [ :safety_accessed, :safety_exited, :chat_searched, :chat_flagged ])
        .order(occurred_at: :desc)
        .limit(100)

      render json: events.map { |a| serialize_event(a) }
    end

    # POST /demo/safety/flag_conversation
    def flag_conversation
      student_name   = params[:student_name].to_s.strip
      channel_id     = params[:channel_id]
      channel_name   = params[:channel_name].to_s.strip
      note           = params[:note].to_s.strip
      notify_targets = Array(params[:notify]).map(&:to_s)

      return render json: { error: "Note is required" }, status: :unprocessable_entity if note.blank?
      return render json: { error: "Select at least one recipient" }, status: :unprocessable_entity if notify_targets.empty?

      log_activity(:chat_flagged, {
        student_name:  student_name,
        channel_id:    channel_id,
        channel_name:  channel_name,
        note:          note,
        notify:        notify_targets,
        accessor_role: accessor_role_label,
        notes:         "#{current_user.full_name} flagged #{student_name} in ##{channel_name}: #{note.truncate(120)}"
      })

      school_ids = accessible_school_ids
      meta       = {
        flagging_user_id:   current_user.id,
        flagging_user_name: current_user.full_name,
        flagging_user_role: accessor_role_label,
        student_name:       student_name,
        channel_name:       channel_name,
        note:               note
      }.to_json

      recipients = []
      if notify_targets.include?("ad")
        recipients += User.joins(:institution_roles)
          .where(institution_roles: { role: :athletic_director, school_id: school_ids })
          .distinct.to_a
      end
      if notify_targets.include?("school_admin")
        recipients += User.joins(:institution_roles)
          .where(institution_roles: { role: :school_admin, school_id: school_ids })
          .distinct.to_a
      end

      notified = []
      recipients.uniq(&:id).each do |recipient|
        next if recipient.id == current_user.id
        Notification.create!(
          recipient:         recipient,
          notification_type: "safety_flag",
          title:             "Safety concern flagged: #{student_name}",
          body:              "#{current_user.full_name} flagged a conversation in ##{channel_name} — #{note.truncate(100)}",
          metadata:          meta,
        )
        notified << recipient.full_name
      end

      render json: { ok: true, notified: }
    rescue => e
      Rails.logger.warn("[Demo::SafetyController] flag_conversation error: #{e.message}")
      render json: { error: "Failed to send flag" }, status: :internal_server_error
    end

    private

    def require_safety_session
      # API clients (Electron/mobile) can't use session cookies when credentials are omitted.
      # Accept a signed safety JWT via X-Safety-Token header as the primary path.
      token = request.headers["X-Safety-Token"].presence
      if token
        begin
          payload = JWT.decode(token, Rails.application.secret_key_base, true, algorithms: [ "HS256" ])[0]
          return if payload["safety"] && payload["sub"] == current_user&.id
        rescue JWT::DecodeError, JWT::ExpiredSignature
          nil
        end
        return render json: { error: "Safety session required" }, status: :forbidden
      end

      # Fall back to session cookie (browser clients with credentials: 'include')
      unless session[:safety_verified_at] && session[:safety_user_id] == current_user&.id
        render json: { error: "Safety session required" }, status: :forbidden
      end
    end

    def parse_date(val)
      Date.parse(val) if val.present?
    rescue ArgumentError
      nil
    end

    def log_activity(event_type, metadata = {})
      school = current_user.institution_roles.first&.school ||
               School.find_by(id: current_user.season_memberships.joins(season: :sport).pick("sports.school_id"))

      Activity.create!(
        event_type:  event_type,
        actor:       current_user,
        school:      school,
        occurred_at: Time.current,
        metadata:    metadata
      )
    rescue => e
      Rails.logger.warn("[Demo::SafetyController] Could not write activity: #{e.message}")
    end

    def accessor_role_label
      @accessor_role_label ||= begin
        return "district_admin"    if current_user.institution_roles.where(role: :district_admin).exists?
        return "school_admin"      if current_user.institution_roles.where(role: :school_admin).exists?
        return "athletic_director" if current_user.institution_roles.where(role: :athletic_director).exists?
        return "head_coach"        if current_user.season_memberships.where(role: :head_coach).exists?
        "staff"
      end
    end

    def notify_supervisors_of_access
      role = accessor_role_label
      return if %w[athletic_director school_admin district_admin super_admin].include?(role)

      school_label = accessor_school_label
      meta = { accessor_id: current_user.id, accessor_name: current_user.full_name,
               accessor_role: role, accessor_schools: accessor_school_names }.to_json

      supervisor_recipients.each do |user|
        next if user.id == current_user.id
        label = user.institution_roles.where(role: :district_admin).exists? ? school_label : ""
        body  = "#{current_user.full_name} (#{role.titleize}#{label}) opened the student safety chat viewer"
        Notification.create!(
          recipient:         user,
          notification_type: "safety_chat_access",
          title:             "Safety: Chat Viewer Accessed",
          body:              body,
          metadata:          meta
        )
      end
    rescue => e
      Rails.logger.warn("[Demo::SafetyController] Could not send access notifications: #{e.message}")
    end

    def notify_supervisors(names, notes)
      role = accessor_role_label
      school_label = accessor_school_label
      meta = { accessor_id: current_user.id, accessor_name: current_user.full_name,
               accessor_role: role, accessor_schools: accessor_school_names,
               searched_names: names }.to_json

      supervisor_recipients.each do |user|
        next if user.id == current_user.id
        label = user.institution_roles.where(role: :district_admin).exists? ? school_label : ""
        body  = "#{current_user.full_name} (#{role.titleize}#{label}) accessed student chats — #{notes}"
        Notification.create!(
          recipient:         user,
          notification_type: "safety_chat_access",
          title:             "Safety: Chat Viewer Access",
          body:              body,
          metadata:          meta
        )
      end
    rescue => e
      Rails.logger.warn("[Demo::SafetyController] Could not create notifications: #{e.message}")
    end

    def accessor_school_names
      @accessor_school_names ||= begin
        # Institution role gives school directly (ADs, admins)
        inst_school = current_user.institution_roles.first&.school
        if inst_school
          [ inst_school.name ]
        else
          # Coaches: derive from their active season memberships
          School.joins(sports: { seasons: :season_memberships })
                .where(season_memberships: { user: current_user })
                .distinct
                .pluck(:name)
        end
      end
    end

    def accessor_school_label
      names = accessor_school_names
      names.any? ? " · #{names.join(', ')}" : ""
    end

    def supervisor_recipients
      users = []

      # Always notify district admins
      users += User.joins(:institution_roles).where(institution_roles: { role: :district_admin }).distinct.to_a

      # If accessor is not an AD or higher, also notify the athletic directors of their schools
      unless %w[athletic_director school_admin district_admin].include?(accessor_role_label)
        school_ids = current_user.season_memberships.joins(season: :sport).pluck("sports.school_id").uniq
        users += User.joins(:institution_roles)
                     .where(institution_roles: { role: :athletic_director, school_id: school_ids })
                     .distinct.to_a
      end

      users.uniq(&:id)
    end

    def serialize_event(activity)
      m = activity.metadata
      {
        id:          activity.id,
        event_type:  activity.event_type,
        occurred_at: activity.occurred_at.iso8601,
        notes:       m["notes"],
        reason:      m["reason"],
        duration_seconds: m["duration_seconds"],
        accessor_role:    m["accessor_role"],
        student_names:    m["student_names"],
        keyword:          m["keyword"]
      }
    end

    def find_members(names)
      school_ids = accessible_school_ids
      scope = User.joins(season_memberships: { season: { sport: :school } })
                  .where(sports: { school_id: school_ids })
                  .distinct
      names.flat_map do |name|
        scope.where(
          "LOWER(users.first_name || ' ' || users.last_name) LIKE :q OR LOWER(users.first_name) LIKE :q OR LOWER(users.last_name) LIKE :q",
          q: "%#{name.downcase}%"
        ).to_a
      end.uniq(&:id)
    end

    def accessible_school_ids
      inst_role = current_user.institution_roles.first
      if inst_role&.district_id.present?
        School.where(district_id: inst_role.district_id).pluck(:id)
      elsif inst_role&.school_id.present?
        [ inst_role.school_id ]
      else
        current_user.season_memberships.joins(season: :sport).pluck("sports.school_id").uniq
      end
    end

    def build_results(members, from, to, keyword)
      members.map do |member|
        channels = Channel
          .joins(:channel_memberships)
          .where(channel_memberships: { user: member })
          .includes(:season)
          .order(:name)

        channel_results = channels.filter_map do |channel|
          messages = channel.messages
            .includes(:sender)
            .where(created_at: from.beginning_of_day..to.end_of_day)
            .order(:created_at)

          messages = messages.where("LOWER(content) LIKE ?", "%#{keyword.downcase}%") if keyword
          next if messages.empty?

          {
            channel_id:   channel.id,
            channel_name: channel.name,
            channel_type: channel.channel_type,
            sport:        channel.season&.sport&.name,
            season:       channel.season&.name,
            messages:     messages.map { |m| serialize_message(m) }
          }
        end

        { student_id: member.id, student_name: member.full_name, channels: channel_results }
      end
    end

    def serialize_message(message)
      {
        id:          message.id,
        content:     message.content,
        sender_name: message.sender.full_name,
        sender_role: sender_role(message.sender),
        sent_at:     message.created_at.iso8601,
        flagged:     message.flagged,
        flag_action: message.flag_action,
        deleted:     message.deleted?
      }
    end

    def sender_role(user)
      return "student"    if user.season_memberships.where(role: :student).exists?
      return "head_coach" if user.season_memberships.where(role: :head_coach).exists?
      "coach"
    end
  end
end
