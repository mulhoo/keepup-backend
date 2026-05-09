class NewMessageNotifier < Noticed::Event
  deliver_by :action_cable do |config|
    config.channel = "UserNotificationsChannel"
    config.stream  = -> { "user_feed:#{recipient.id}" }
    config.message = -> {
      msg = record
      {
        type:       "push_new_message",
        channel_id: msg.channel_id,
        sender:     msg.sender.full_name,
        preview:    msg.flag_action == "held" ? nil : msg.content&.truncate(80)
      }
    }
  end

  # FCM delivery added when firebase-admin gem is configured.

  param :message

  def record
    params[:message]
  end
end
