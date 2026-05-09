class AddEmojiAppealAndGemmaFeedback < ActiveRecord::Migration[8.0]
  def change
    # Expanded status enum (integer):
    #   0 = pending       — Gemma cleared; awaiting captain/coach approval
    #   1 = approved      — human approved
    #   2 = rejected      — human rejected
    #   3 = auto_rejected — Gemma flagged; student may appeal
    #   4 = appealed      — student has contested the auto_rejection; awaiting coach review

    # Tracks the student's appeal of a Gemma auto-rejection.
    add_column :sport_emojis, :appeal_reason, :text
    add_column :sport_emojis, :appealed_at, :datetime
    add_column :sport_emojis, :appeal_reviewed_by_id, :bigint
    add_column :sport_emojis, :appeal_reviewed_at, :datetime

    # True when a coach approved an emoji that Gemma had auto_rejected.
    # These records are pulled as few-shot context for future Gemma moderation calls
    # on the same sport — "previously approved for this team despite initial concerns."
    add_column :sport_emojis, :gemma_overridden, :boolean, default: false, null: false

    add_index :sport_emojis, :gemma_overridden
    add_index :sport_emojis, :appealed_at

    add_foreign_key :sport_emojis, :users, column: :appeal_reviewed_by_id
  end
end
