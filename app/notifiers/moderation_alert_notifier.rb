class ModerationAlertNotifier < Noticed::Event
  deliver_by :action_cable do |config|
    config.channel = "UserNotificationsChannel"
    config.stream  = -> { "user_feed:#{recipient.id}" }
    config.message = -> {
      notif = record
      {
        type:     "moderation_alert",
        alert_id: notif.id,
        severity: notif.notification_type,
        unread:   true
      }
    }
  end

  # FCM delivery added when firebase-admin gem is configured.
  # See config/initializers/noticed.rb for credential setup.

  param :moderation_notification

  def record
    params[:moderation_notification]
  end
end
