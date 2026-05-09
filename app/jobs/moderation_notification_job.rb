class ModerationNotificationJob < ApplicationJob
  queue_as :default

  # Creates ModerationNotification records for the appropriate recipients based on tier.
  #
  # tier "questionable" → head coach(es) of the sport notified for review
  # tier "severe"       → head coach(es) + athletic director notified immediately
  #
  # The notification record references the flagged message — recipients click through
  # to the admin dashboard to view content. Message content is never embedded in the
  # notification record itself (COPPA/FERPA safety).
  def perform(flagged_record_type, flagged_record_id, tier)
    record = flagged_record_type.constantize.find_by(id: flagged_record_id)
    return unless record

    sport = sport_for(record)
    return unless sport

    head_coaches = sport.head_coaches
    notify_recipients(head_coaches, record, tier, :head_coach)

    if tier == "severe"
      ad = InstitutionRole.athletic_director.find_by(school: sport.school)&.user
      notify_recipients([ ad ].compact, record, tier, :athletic_director)
    end
  end

  private

  def sport_for(record)
    case record
    when Message       then record.channel.sport
    when DirectMessage then record.dm_conversation.sport
    end
  end

  def notify_recipients(users, record, tier, role)
    notification_type = tier == "severe" ? :severe_alert : :questionable_review
    message_key = record.is_a?(Message) ? :message : :direct_message

    users.each do |user|
      notif = ModerationNotification.create!(
        recipient: user,
        message_key => record,
        notification_type: notification_type,
        recipient_role: role
      )
      ModerationAlertNotifier.with(moderation_notification: notif).deliver(user)
    end
  end
end
