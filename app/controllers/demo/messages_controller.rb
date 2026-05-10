module Demo
  class MessagesController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode
    before_action :require_channel, only: %i[index create]
    before_action :require_message, only: %i[translate]

    STAFF_SEASON_ROLES = %w[head_coach assistant_coach].freeze

    def index
      messages = visible_messages.order(created_at: :asc).limit(50)
      render json: messages.map { |m| serialize_message(m, current_user) }
    end

    def create
      message = @channel.messages.build(sender: current_user, content: params[:content].to_s.strip)
      return render json: { error: "Content can't be blank" }, status: :unprocessable_entity if message.content.blank?

      result = moderate(message.content)
      Gemma::ContentModerator.call(message, score: result[:score], reason: result[:reason])
      message.save!

      tier = moderation_tier(message)
      ModerationNotificationJob.perform_later("Message", message.id, tier) if message.flagged?
      BroadcastMessageJob.perform_later(message.id)

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

    def translate
      target_language = current_user.preferred_language

      if target_language.blank?
        return render json: {
          error:               "No preferred language set on your account.",
          supported_languages: Gemma::Translator::SUPPORTED_LANGUAGES
        }, status: :unprocessable_entity
      end

      # Student-authored content is translated on-device by Gemma in the mobile app.
      # The web demo can't run Gemma locally, so we explain what happens instead.
      unless staff_authored?(@message)
        return render json: {
          message_id:      @message.id,
          on_device:       true,
          translation_path: "on_device",
          note:            "In the KeepUp mobile app, Gemma translates this message directly on your device — no content is ever sent to a server.",
          demo_app_note:   "Download the KeepUp demo app to see on-device translation in action."
        }
      end

      # Serve from cache if already translated into this language
      cached = @message.message_translations.find_by(language: target_language)
      if cached
        return render json: translation_response(@message, cached.translated_text, target_language, from_cache: true)
      end

      context = @message.channel.broadcast? ? "announcement" : "message"
      result  = Gemma::Translator.translate(text: @message.content, target_language:, context:)

      @message.message_translations.create!(language: target_language, translated_text: result.translated_text)

      render json: translation_response(@message, result.translated_text, target_language,
                                        language_name: result.language_name, from_cache: false)

    rescue GemmaClient::ServiceUnavailable
      render json: { error: "Translation service temporarily unavailable." }, status: :service_unavailable
    end

    private

    def require_demo_mode
      render json: { error: "Not found" }, status: :not_found unless Rails.application.config.demo_mode
    end

    def require_channel
      @channel = Channel.active.find_by(id: params[:channel_id])
      return render json: { error: "Channel not found" }, status: :not_found unless @channel
      return render json: { error: "Not authorized for this channel" }, status: :forbidden unless @channel.viewable_by?(current_user)
    end

    def require_message
      @message = Message.find_by(id: params[:id])
      return render json: { error: "Message not found" }, status: :not_found unless @message
      return render json: { error: "Not authorized" }, status: :forbidden unless @message.channel.viewable_by?(current_user)
    end

    def staff_authored?(message)
      sender = message.sender
      return true if sender.institution_roles.exists?

      season = message.channel.season
      role   = sender.season_memberships.find_by(season:)&.role
      STAFF_SEASON_ROLES.include?(role)
    end

    def translation_response(message, translated_text, target_language, language_name: nil, from_cache: false)
      language_name ||= Gemma::Translator::SUPPORTED_LANGUAGES[target_language]
      {
        message_id:      message.id,
        original_text:   message.content,
        translated_text: translated_text,
        target_language: target_language,
        language_name:   language_name,
        from_cache:      from_cache
      }
    end

    def moderate(content)
      response = GemmaClient.post("/moderate", { content:, context: "demo" })
      { score: response[:score].to_f, reason: response[:reason], source: "gemma4" }
    rescue GemmaClient::ServiceUnavailable
      Demo::KeywordModerator.score(content).merge(source: "keyword_fallback")
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
      recipients += [{ role: "athletic_director", name: ad.full_name }] if tier == "severe" && ad
      recipients
    end

    def visible_messages(scope = @channel.messages)
      if current_user.coach_of_season?(@channel.season) || current_user.institution_roles.exists?
        scope.where(deleted_at: nil).where.not(flag_action: "blocked")
      else
        scope.visible.or(scope.where(sender: current_user, deleted_at: nil))
      end
    end

    def serialize_message(msg, viewer)
      is_sender = msg.sender_id == viewer.id
      blocked   = msg.flag_action == "blocked"
      {
        id:               msg.id,
        content:          display_content(msg, viewer, is_sender),
        sender:           msg.sender.full_name,
        sender_id:        msg.sender_id,
        flag_action:      msg.flag_action,
        flagged:          msg.flagged,
        created_at:       msg.created_at.iso8601,
        indicator:        flag_indicator(msg, is_sender),
        translatable:     !blocked,
        translation_path: blocked ? nil : (staff_authored?(msg) ? "server" : "on_device")
      }
    end

    def display_content(msg, viewer, is_sender)
      case msg.flag_action
      when "blocked" then is_sender ? "[Your message was blocked 🚫]" : nil
      when "held"    then (is_sender || current_user.coach_of_season?(msg.channel.season)) ? msg.content : nil
      else msg.content
      end
    end

    def flag_indicator(msg, is_sender)
      case msg.flag_action
      when "blocked" then is_sender ? "🚫" : nil
      when "held"    then "⚠️"
      end
    end
  end
end
