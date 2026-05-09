class MessageFlag < ApplicationRecord
  belongs_to :message
  belongs_to :flagged_by, class_name: "User"
  belongs_to :reviewed_by, class_name: "User", optional: true
  belongs_to :escalated_to, class_name: "User", optional: true
  belongs_to :resolved_by, class_name: "User", optional: true

  enum :status, {
    pending:   0,
    reviewed:  1,
    escalated: 2,
    resolved:  3
  }

  validates :message, :flagged_by, presence: true
  validates :message_id, uniqueness: { scope: :flagged_by_id, message: "has already been flagged by this user" }

  def escalate!(to_user)
    update!(status: :escalated, escalated_to: to_user, escalated_at: Time.current)
  end

  def resolve!(by_user)
    update!(status: :resolved, resolved_by: by_user, resolved_at: Time.current)
  end
end
