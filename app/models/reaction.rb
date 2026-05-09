class Reaction < ApplicationRecord
  belongs_to :message, optional: true
  belongs_to :direct_message, optional: true
  belongs_to :sport_emoji, optional: true
  belongs_to :user

  validates :emoji, presence: true
  validate :exactly_one_target
  validates :user_id, uniqueness: { scope: [:message_id, :emoji] }, if: -> { message_id.present? }
  validates :user_id, uniqueness: { scope: [:direct_message_id, :emoji] }, if: -> { direct_message_id.present? }

  private

  def exactly_one_target
    if message_id.present? == direct_message_id.present?
      errors.add(:base, "must belong to exactly one of message or direct_message")
    end
  end
end
