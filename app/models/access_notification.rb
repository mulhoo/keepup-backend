class AccessNotification < ApplicationRecord
  belongs_to :notified_user, class_name: "User"
  belongs_to :access_log

  scope :unread, -> { where(read_at: nil) }

  def mark_read!
    update!(read_at: Time.current)
  end
end
