class DirectMessage < ApplicationRecord
  belongs_to :dm_conversation
  belongs_to :sender, class_name: "User"
  belongs_to :flag_reviewed_by, class_name: "User", optional: true

  validates :content, presence: true

  scope :visible, -> { where(deleted_at: nil).where.not(flag_action: "blocked") }
  scope :visible_to_sender, ->(user) { where(deleted_at: nil).where(sender: user).or(where(deleted_at: nil).where.not(flag_action: "blocked")) }
  scope :flagged, -> { where(flagged: true) }
  scope :pending_review, -> { where(flagged: true, flag_reviewed: false) }
  scope :blocked, -> { where(flag_action: "blocked") }
  scope :held, -> { where(flag_action: "held") }

  after_create :touch_conversation

  def soft_delete!
    update!(deleted_at: Time.current)
  end

  def read!(at: Time.current)
    update!(read_at: at)
  end

  def apply_moderation_result!(score:, flagged:, reason: nil)
    update!(
      moderation_score: score,
      flagged: flagged,
      flag_reason: reason
    )
  end

  private

  def touch_conversation
    dm_conversation.update_column(:last_message_at, created_at)
  end
end
