module Demo
  class MessagesController < Demo::ApplicationController
    include DemoGuard
    before_action :require_demo_mode
    before_action :require_channel, only: %i[index create]
    before_action :require_message, only: %i[translate report remove]

    STAFF_SEASON_ROLES = %w[head_coach assistant_coach].freeze

    def index
      messages = visible_messages
        .includes(:message_thread_as_parent, reactions: :user, sender: [ :institution_roles, :season_memberships ])
        .order(created_at: :asc).limit(50)
      render json: messages.map { |m| serialize_message(m, current_user) }
    end

    def create
      message = @channel.messages.build(sender: current_user, content: params[:content].to_s.strip)
      return render json: { error: "Content can't be blank" }, status: :unprocessable_entity if message.content.blank?
      return render json: { error: "Content too long" }, status: :unprocessable_entity if message.content.length > 2000

      sender_role = resolve_sender_role
      result = moderate(message.content, sender_role)
      Gemma::ContentModerator.call(message, score: result[:score], reason: result[:reason], category: result[:category])
      message.save!

      tier = moderation_tier(message)
      Rails.logger.info("[Demo::Messages] moderation source=#{result[:source]} score=#{result[:score].round(3)} tier=#{tier} channel=#{@channel.id} message=#{message.id}")
      ModerationNotificationJob.perform_later("Message", message.id, tier) if message.flagged?
      BroadcastMessageJob.perform_later(message.id)
      PreTranslateMessageJob.perform_later(message.id) unless sender_role == "student"

      render json: {
        message:   serialize_message(message, current_user),
        moderation: {
          score:                 result[:score],
          tier:                  tier,
          flag_action:           message.flag_action,
          reason:                result[:reason],
          source:                result[:source],
          visible_to_others:     !%w[held blocked].include?(message.flag_action),
          notifications_sent_to: notification_recipients(message, tier)
        }
      }, status: :created
    end

    def report
      notes = params[:notes].to_s.strip

      unless @message.flag_action == "blocked"
        @message.update!(
          flagged:      true,
          flag_action:  "held",
          flag_reason:  @message.flag_reason.presence || "Reported by user",
          report_notes: notes.presence
        )
      else
        @message.update!(report_notes: notes.presence) if notes.present?
      end

      ModerationNotificationJob.perform_later("Message", @message.id, "questionable")

      render json: { reported: true, message_id: @message.id }, status: :ok
    end

    def remove
      return render json: { error: "Forbidden" }, status: :forbidden unless coach_or_admin?

      return render json: { ok: true, message_id: @message.id } if @message.flag_action == "removed"

      remove_thread = params[:remove_thread] == true || params[:remove_thread] == "true"

      removal_attrs = {
        flagged:          true,
        flag_action:      "removed",
        flag_reviewed:    true,
        flag_reviewed_by: current_user,
        flag_reviewed_at: Time.current,
        flag_reason:      @message.flag_reason.presence || "Removed by coach"
      }

      ActiveRecord::Base.transaction do
        targets = if @message.broadcast_id.present?
          Message.where(broadcast_id: @message.broadcast_id)
        else
          Message.where(id: @message.id)
        end

        targets.where("flag_action IS NULL OR flag_action != 'removed'")
               .update_all(removal_attrs.merge(flag_reviewed_by_id: current_user.id).except(:flag_reviewed_by))

        if remove_thread && (thread = @message.message_thread_as_parent)
          thread.messages.each do |reply|
            reply.update!(removal_attrs.merge(flag_reason: "Thread removed by coach"))
          end
        end
      end

      render json: { removed: true, message_id: @message.id }, status: :ok
    end

    def translate
      target_language = current_user.preferred_language

      if target_language.blank?
        return render json: { error: "No preferred language set on your account." }, status: :unprocessable_entity
      end

      unless staff_authored?(@message)
        return render json: {
          message_id:      @message.id,
          on_device:       true,
          translation_path: "on_device",
          note:            "In the KeepUp mobile app, Gemma translates this message directly on your device — no content is ever sent to a server.",
          demo_app_note:   "Download the KeepUp demo app to see on-device translation in action."
        }
      end

      cached = @message.message_translations.find_by(language: target_language)
      if cached
        return render json: translation_response(@message, cached.translated_text, target_language, from_cache: true)
      end

      result = if DeeplTranslator.available?
        DeeplTranslator.translate(text: @message.content, target_language:)
      else
        context = @message.channel.broadcast? ? "announcement" : "message"
        Gemma::Translator.translate(text: @message.content, target_language:, context:)
      end

      @message.message_translations.create!(language: target_language, translated_text: result.translated_text)

      render json: translation_response(@message, result.translated_text, target_language,
                                        language_name: result.language_name, from_cache: false)

    rescue GemmaClient::ServiceUnavailable
      render json: { error: "Translation service temporarily unavailable." }, status: :service_unavailable
    end

    private

    def coach_or_admin?
      return true if current_user.institution_roles.exists?
      season = @message.channel&.season
      return false unless season
      current_user.season_memberships.active
        .where(season: season, role: %w[head_coach assistant_coach])
        .exists?
    end

    def require_channel
      @channel = Channel.active.find_by(id: params[:channel_id])
      return render json: { error: "Channel not found" }, status: :not_found unless @channel
      render json: { error: "Not authorized for this channel" }, status: :forbidden unless @channel.viewable_by?(current_user)
    end

    def require_message
      @message = Message.find_by(id: params[:id])
      return render json: { error: "Message not found" }, status: :not_found unless @message
      render json: { error: "Not authorized" }, status: :forbidden unless @message.channel.viewable_by?(current_user)
    end

    def sender_role_for(msg)
      sender = msg.sender
      # institution_roles and season_memberships are eager-loaded — use Ruby finders to avoid N+1
      inst = sender.institution_roles.min_by(&:id)
      return inst.role if inst
      sm = sender.season_memberships.find { |m| m.season_id == @channel.season_id }
      return nil unless sm
      sm.student? && sm.is_captain? ? "student_captain" : sm.role
    end

    def staff_authored?(message)
      sender = message.sender
      return true if sender.institution_roles.any?
      sm = sender.season_memberships.find { |m| m.season_id == @channel.season_id }
      STAFF_SEASON_ROLES.include?(sm&.role)
    end

    def translation_response(message, translated_text, target_language, language_name: nil, from_cache: false)
      language_name ||= target_language
      {
        message_id:      message.id,
        original_text:   message.content,
        translated_text: translated_text,
        target_language: target_language,
        language_name:   language_name,
        from_cache:      from_cache
      }
    end

    def resolve_sender_role
      inst = current_user.institution_roles.min_by(&:id)
      return inst.role.to_s if inst
      current_user.season_memberships.find_by(season_id: @channel.season_id)&.role.to_s || "student"
    end

    def moderate(content, sender_role)
      sport             = @channel.season&.sport
      sport_template_id = sport&.sport_template_id
      school_id         = sport&.school_id

      if sender_role == "student"
        return Demo::KeywordModerator.score(content, sport_template_id:, school_id:).merge(source: "keyword_prefilter")
      end

      response = GemmaClient.post("/moderate", { content:, sender_role: })
      { score: response[:score].to_f, reason: response[:reason], category: response[:category], source: "gemma4" }
    rescue GemmaClient::ServiceUnavailable
      Demo::KeywordModerator.score(content, sport_template_id:, school_id:).merge(source: "keyword_fallback")
    end

    def moderation_tier(message)
      return "severe"       if message.flag_action == "blocked"
      return "questionable" if message.flag_action == "held"
      "clear"
    end

    def notification_recipients(message, tier)
      return [] unless message.flagged?

      season     = @channel.season
      coaches    = season.head_coaches.map { |u| { role: "head_coach", name: u.full_name } }
      ad         = InstitutionRole.athletic_director.find_by(school: season.school)&.user
      recipients = coaches
      recipients += [ { role: "athletic_director", name: ad.full_name } ] if tier == "severe" && ad
      recipients
    end

    def visible_messages(scope = @channel.messages)
      # flag_action is NULL for clear messages, "held" for questionable, "blocked" for severe.
      # SQL: flag_action != 'blocked' does NOT include NULLs, so we need an explicit IS NULL check.
      scope.where(deleted_at: nil)
           .where("flag_action IS NULL OR flag_action NOT IN ('blocked')")
           .where(message_thread_id: nil)
    end

    def display_name_for(user, role)
      return user.full_name unless %w[student student_captain].include?(role)

      case user.name_display
      when "first_only"         then user.first_name
      when "first_last_initial" then "#{user.first_name} #{user.last_name[0]}."
      else user.full_name
      end
    end

    def serialize_message(msg, viewer)
      is_sender = msg.sender_id == viewer.id
      blocked   = msg.flag_action == "blocked"
      role      = sender_role_for(msg)

      reactions = msg.reactions.group_by(&:emoji).map do |emoji, rxns|
        { emoji: emoji, count: rxns.size, reacted: rxns.any? { |r| r.user_id == viewer.id }, users: rxns.map { |r| r.user.first_name } }
      end

      {
        id:               msg.id,
        content:          display_content(msg, is_sender),
        sender:           display_name_for(msg.sender, role),
        sender_id:        msg.sender_id,
        sender_role:      role,
        sender_pronouns:  msg.sender.pronouns.presence,
        flag_action:      msg.flag_action,
        flagged:          msg.flagged,
        created_at:       msg.created_at.iso8601,
        indicator:        flag_indicator(msg, is_sender),
        translatable:     !blocked,
        translation_path: blocked ? nil : (staff_authored?(msg) ? "server" : "on_device"),
        reactions:        reactions,
        reply_count:      msg.message_thread_as_parent&.reply_count || 0
      }
    end

    def display_content(msg, is_sender)
      return (is_sender ? "[Your message was blocked 🚫]" : nil) if msg.flag_action == "blocked"
      return nil if msg.flag_action == "removed"
      msg.content
    end

    def flag_indicator(msg, is_sender)
      # Only severe (blocked) messages get an indicator, and only for the sender.
      # Questionable (held) messages deliver silently — no flag shown to anyone.
      msg.flag_action == "blocked" && is_sender ? "🚫" : nil
    end
  end
end
