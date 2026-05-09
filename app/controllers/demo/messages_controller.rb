module Demo
  class MessagesController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode
    before_action :require_channel

    THRESHOLDS = Rails.application.config.gemma

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
        message:            serialize_message(message, current_user),
        moderation: {
          score:      result[:score],
          tier:       tier,
          flag_action: message.flag_action,
          reason:     result[:reason],
          source:     result[:source],
          visible_to_others: message.flag_action != "held" && message.flag_action != "blocked",
          notifications_sent_to: notification_recipients(message, tier)
        }
      }, status: :created
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

    def moderate(content)
      begin
        response = GemmaClient.post("/moderate", { content: content, context: "demo" })
        { score: response[:score].to_f, reason: response[:reason], source: "gemma4" }
      rescue GemmaClient::ServiceUnavailable
        result = Demo::KeywordModerator.score(content)
        result.merge(source: "keyword_fallback")
      end
    end

    def moderation_tier(message)
      return "severe"       if message.flag_action == "blocked"
      return "questionable" if message.flag_action == "held"
      "clear"
    end

    def notification_recipients(message, tier)
      return [] unless message.flagged?

      sport   = @channel.sport
      coaches = sport.head_coaches.map { |u| { role: "head_coach", name: u.full_name } }
      ad      = InstitutionRole.athletic_director.find_by(school: sport.school)&.user

      recipients = coaches
      recipients += [{ role: "athletic_director", name: ad.full_name }] if tier == "severe" && ad
      recipients
    end

    def visible_messages(scope = @channel.messages)
      if current_user.coach_of?(@channel.sport) || current_user.institution_roles.exists?
        scope.where(deleted_at: nil).where.not(flag_action: "blocked")
      else
        scope.visible.or(scope.where(sender: current_user, deleted_at: nil))
      end
    end

    def serialize_message(msg, viewer)
      is_sender = msg.sender_id == viewer.id
      {
        id:          msg.id,
        content:     display_content(msg, viewer, is_sender),
        sender:      msg.sender.full_name,
        sender_id:   msg.sender_id,
        flag_action: msg.flag_action,
        flagged:     msg.flagged,
        created_at:  msg.created_at.iso8601,
        indicator:   flag_indicator(msg, is_sender)
      }
    end

    def display_content(msg, viewer, is_sender)
      case msg.flag_action
      when "blocked"
        is_sender ? "[Your message was blocked 🚫]" : nil
      when "held"
        (is_sender || current_user.coach_of?(@channel.sport)) ? msg.content : nil
      else
        msg.content
      end
    end

    def flag_indicator(msg, is_sender)
      case msg.flag_action
      when "blocked"    then is_sender ? "🚫" : nil
      when "held"       then "⚠️"
      end
    end
  end
end
