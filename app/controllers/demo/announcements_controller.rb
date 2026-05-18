module Demo
  class AnnouncementsController < Demo::ApplicationController
    include DemoGuard
    before_action :require_demo_mode

    def index
      channel_ids = accessible_announcement_channels.pluck(:id)
      sent = Message
        .where(channel_id: channel_ids, deleted_at: nil)
        .where("scheduled_at IS NULL OR scheduled_at <= ?", Time.current)
        .includes(:sender, channel: { season: { sport: [ :school, :sport_template ] } })
        .order(created_at: :desc)
        .limit(50)

      scheduled = Message
        .where(channel_id: channel_ids, deleted_at: nil)
        .where("scheduled_at > ?", Time.current)
        .includes(:sender, channel: { season: { sport: [ :school, :sport_template ] } })
        .order(scheduled_at: :asc)

      render json: {
        sent:      group_messages(sent),
        scheduled: group_messages(scheduled)
      }
    end

    def create
      content = params[:content].to_s.strip
      return render json: { error: "Content is required" }, status: :unprocessable_entity if content.blank?

      moderation_score = nil
      moderation_reason = nil

      begin
        moderation = GemmaClient.post("/moderate", { content:, sender_role: gemma_sender_role })
        moderation_score  = moderation[:score].to_f
        moderation_reason = moderation[:reason]
      rescue GemmaClient::ServiceUnavailable
        kw = Demo::KeywordModerator.score(content)
        moderation_score  = kw[:score].to_f
        moderation_reason = kw[:reason]
      end

      if moderation_score >= 0.75
        Activity.create!(
          user:       current_user,
          event_type: :message_flagged,
          metadata:   { source: "announcement", tier: "severe", blocked: true, reason: moderation_reason }
        )
        return render json: {
          error:     "Your announcement was blocked — it was flagged as inappropriate.",
          moderated: true,
          tier:      "severe",
          reason:    moderation_reason
        }, status: :unprocessable_entity
      end

      scheduled_at = parse_scheduled_at(params[:scheduled_at])
      channels     = target_channels

      return render json: { error: "No matching sports found" }, status: :unprocessable_entity if channels.empty?

      broadcast_id = SecureRandom.uuid
      channels.each { |ch| Message.create!(channel: ch, sender: current_user, content: content, scheduled_at: scheduled_at, broadcast_id: broadcast_id) }

      render json: {
        sent_count:   channels.count,
        sports:       channels.map { |ch| sport_label(ch) },
        label:        recipient_label(channels),
        scheduled_at: scheduled_at&.iso8601
      }
    end

    private

    def accessible_announcement_channels
      role = current_user.institution_roles.first
      return Channel.none unless role

      base = Channel
        .joins(season: { sport: [ :school, :sport_template ] })
        .where(name: "announcements", channel_type: :broadcast)

      if role.super_admin?
        base
      elsif role.district_admin?
        base.where(schools: { district_id: role.district_id })
      elsif role.school_admin? || role.athletic_director?
        base.where(sports: { school_id: role.school_id })
      else
        season_ids = current_user.season_memberships.where(status: :active).pluck(:season_id)
        base.where(seasons: { id: season_ids })
      end
    end

    def target_channels
      base = accessible_announcement_channels.where(seasons: { status: :active })

      if params[:sport_ids].present?
        sport_ids = Array(params[:sport_ids]).map(&:to_i)
        base = base.where(sports: { id: sport_ids })
      end

      if params[:school_ids].present?
        school_ids = Array(params[:school_ids]).map(&:to_i)
        base = base.where(schools: { id: school_ids })
      end

      if params[:athletic_season].present?
        base = base.where(sport_templates: { athletic_season: params[:athletic_season] })
      end

      # One channel per sport — pick the most recent season (highest id)
      seen = {}
      base
        .order(id: :desc)
        .includes(season: { sport: [ :school, :sport_template ] })
        .each_with_object([]) do |ch, uniq|
          sport_id = ch.season.sport_id
          next if seen[sport_id]
          seen[sport_id] = true
          uniq << ch
        end
    end

    def group_messages(messages)
      grouped = messages.group_by { |m| [ m.sender_id, m.content, m.scheduled_at ] }
      grouped.map do |_, msgs|
        lead   = msgs.first
        sports = msgs.map { |m| sport_entry(m) }.uniq { |s| s[:id] }
        {
          id:           lead.id,
          content:      lead.content,
          sender:       { id: lead.sender_id, name: "#{lead.sender.first_name} #{lead.sender.last_name}" },
          sports:       sports,
          school_name:  sports.first&.dig(:school_name),
          created_at:   lead.created_at.iso8601,
          scheduled_at: lead.scheduled_at&.iso8601
        }
      end.sort_by { |m| m[:created_at] }.reverse
    end

    def sport_entry(msg)
      sport    = msg.channel.season.sport
      school   = sport.school
      template = sport.sport_template
      { id: sport.id, name: sport.name, gender: sport.gender, school_name: school.name, athletic_season: template&.athletic_season }
    end

    def parse_scheduled_at(raw)
      return nil if raw.blank?
      time = Time.zone.parse(raw.to_s)
      time.future? ? time : nil
    rescue ArgumentError
      nil
    end

    def sport_label(ch)
      sport = ch.season.sport
      "#{sport.gender.capitalize} #{sport.name}"
    end

    def recipient_label(channels)
      if params[:athletic_season].present? && params[:sport_ids].blank?
        "#{params[:athletic_season].to_s.capitalize} Sports"
      elsif params[:sport_ids].blank? && params[:school_ids].blank? && params[:athletic_season].blank?
        "All Teams"
      else
        channels.map { |ch| sport_label(ch) }.join(", ")
      end
    end

    def gemma_sender_role
      role = current_user.institution_roles.first&.role.to_s
      %w[athletic_director school_admin district_admin super_admin].include?(role) ? "admin" : "coach"
    end
  end
end
