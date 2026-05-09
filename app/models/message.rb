class Message < ApplicationRecord
  belongs_to :channel
  belongs_to :message_thread, optional: true
  belongs_to :sender, class_name: "User"
  belongs_to :flag_reviewed_by, class_name: "User", optional: true
  belongs_to :deleted_by, class_name: "User", optional: true

  has_one :message_thread_as_parent,
          class_name: "MessageThread",
          foreign_key: :parent_message_id
  has_many :reactions, dependent: :destroy

  validates :content, presence: true
  validates :channel, :sender, presence: true

  scope :visible, -> { where(deleted_at: nil).where.not(flag_action: "blocked") }
  scope :visible_to_sender, ->(user) { where(deleted_at: nil).where(sender: user).or(where(deleted_at: nil).where.not(flag_action: "blocked")) }
  scope :flagged, -> { where(flagged: true) }
  scope :pending_review, -> { where(flagged: true, flag_reviewed: false) }
  scope :blocked, -> { where(flag_action: "blocked") }
  scope :held, -> { where(flag_action: "held") }

  after_create :increment_thread_reply_count, if: :message_thread_id

  def soft_delete!(deleted_by_user)
    update!(deleted_at: Time.current, deleted_by: deleted_by_user)
  end

  def deleted?
    deleted_at.present?
  end

  # Called by the FastAPI /moderate endpoint response after Gemma 4 on-device flag
  def apply_moderation_result!(score:, flagged:, reason: nil)
    update!(
      moderation_score: score,
      flagged: flagged,
      flag_reason: reason
    )
  end

  private

  def increment_thread_reply_count
    message_thread.increment_reply_count!
  end
end
