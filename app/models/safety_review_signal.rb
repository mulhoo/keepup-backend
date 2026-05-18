class SafetyReviewSignal < ApplicationRecord
  belongs_to :school
  belongs_to :sport_template, optional: true

  enum :decision, { approved: 0, rejected: 1 }

  validates :category, presence: true
  validates :sender_role, presence: true
  validates :decision, presence: true

  # Only look at the last 6 months — older signals decay naturally as team culture evolves
  scope :recent, -> { where(created_at: 6.months.ago..) }
end
