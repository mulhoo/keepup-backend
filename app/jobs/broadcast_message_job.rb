class BroadcastMessageJob < ApplicationJob
  queue_as :default

  def perform(message_id)
    message = Message.includes(:sender, channel: :sport).find_by(id: message_id)
    return unless message

    return if message.flag_action == "blocked"

    payload = {
      type:        "new_message",
      id:          message.id,
      channel_id:  message.channel_id,
      sender_id:   message.sender_id,
      sender_name: message.sender.full_name,
      content:     message.flag_action == "held" ? nil : message.content,
      flag_action: message.flag_action,
      created_at:  message.created_at.iso8601,
      thread_id:   message.message_thread_id
    }

    ActionCable.server.broadcast("channel_feed:#{message.channel_id}", payload)

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
end
