class GemmaModerateMessageJob < ApplicationJob
  queue_as :default

  def perform(message_id, sender_role)
    message = Message.find_by(id: message_id)
    return unless message
    return if message.flag_action == "blocked"

    old_tier = tier_for(message)

    response = GemmaClient.post("/moderate", { content: message.content, sender_role: })
    Gemma::ContentModerator.call(message,
      score:    response[:score].to_f,
      reason:   response[:reason],
      category: response[:category]
    )

    return unless message.changed?

    message.save!
    new_tier = tier_for(message)

    Rails.logger.info("[GemmaModerateMessageJob] tier #{old_tier}→#{new_tier} source=gemma4 message=#{message_id}")

    if new_tier != old_tier
      ModerationNotificationJob.perform_later("Message", message.id, new_tier) if message.flagged?
      ActionCable.server.broadcast("channel_feed:#{message.channel_id}", {
        type:        "message_moderation_updated",
        id:          message.id,
        channel_id:  message.channel_id,
        flag_action: message.flag_action,
        content:     %w[blocked removed].include?(message.flag_action) ? nil : message.content
      })
      if message.flag_action == "held"
        ActionCable.server.broadcast("user_feed:#{message.sender_id}", {
          type:        "message_held",
          id:          message.id,
          channel_id:  message.channel_id,
          content:     message.content,
          flag_action: "held",
          created_at:  message.created_at.iso8601
        })
      end
    end
  rescue GemmaClient::ServiceUnavailable
    Rails.logger.warn("[GemmaModerateMessageJob] Gemma unavailable for message #{message_id}, keeping keyword result")
  end

  private

  def tier_for(message)
    case message.flag_action
    when "blocked" then "severe"
    when "held"    then "questionable"
    else "clear"
    end
  end
end
