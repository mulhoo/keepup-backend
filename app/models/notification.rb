class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"

  TYPES = %w[safety_chat_access moderation_alert].freeze

  scope :unread,  -> { where(read_at: nil) }
  scope :recent,  -> { order(created_at: :desc) }

  def read?
    read_at.present?
  end

  def mark_read!
    update!(read_at: Time.current)
  end

  def parsed_metadata
    JSON.parse(metadata || "{}")
  end
end
