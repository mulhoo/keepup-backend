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

    season = season_for(record)
    return unless season

    head_coaches = season.head_coaches
    notify_recipients(head_coaches, record, tier, :head_coach)

    if tier == "severe"
      ad = InstitutionRole.athletic_director.find_by(school: season.school)&.user
      notify_recipients([ ad ].compact, record, tier, :athletic_director)
    end

    write_activity(record, season, tier)
  end

  private

  def season_for(record)
    case record
    when Message       then record.channel.season
    when DirectMessage then record.dm_conversation.season
    end
  end

  def write_activity(record, season, tier)
    channel = record.is_a?(Message) ? record.channel : record.dm_conversation
    Activity.create!(
      event_type:  :message_flagged,
      actor:       record.sender,
      subject:     record,
      season:      season,
      school:      season.school,
      occurred_at: record.created_at,
      metadata:    {
        tier:        tier,
        flag_action: record.flag_action,
        flag_reason: record.flag_reason,
        sport:       season.sport.name,
        season:      season.name,
        channel:     channel.respond_to?(:name) ? channel.name : "Direct Message"
      }
    )
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
