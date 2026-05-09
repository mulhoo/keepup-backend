class ModerationNotification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :message, optional: true
  belongs_to :direct_message, optional: true

  enum :notification_type, {
    questionable_review: 0,
    severe_alert:        1
  }

  enum :recipient_role, {
    head_coach:        0,
    athletic_director: 1
  }

  validates :notification_type, :recipient_role, presence: true
  validate :message_or_direct_message_present

  scope :unread, -> { where(read_at: nil) }
  scope :pending_review, -> { questionable_review.unread }

  def read!
    update!(read_at: Time.current)
  end

  def flagged_record
    message || direct_message
  end

  def sport
    message&.channel&.sport || direct_message&.dm_conversation&.sport
  end

  private

  def message_or_direct_message_present
    unless message_id.present? ^ direct_message_id.present?
      errors.add(:base, "must reference exactly one of message or direct_message")
    end
  end
end
