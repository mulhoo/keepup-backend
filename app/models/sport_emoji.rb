class SportEmoji < ApplicationRecord
  belongs_to :sport
  belongs_to :requested_by, class_name: "User"
  belongs_to :reviewed_by, class_name: "User", optional: true
  belongs_to :appeal_reviewed_by, class_name: "User", optional: true

  has_many :reactions, dependent: :destroy

  enum :status, {
    pending:       0,
    approved:      1,
    rejected:      2,
    auto_rejected: 3,
    appealed:      4
  }

  validates :name, :image_url, presence: true
  validates :name, uniqueness: { scope: :sport_id, message: "already exists for this sport" }
  validates :name, format: { with: /\A:[a-z0-9_]+:\z/, message: "must be in :name: format" }

  scope :available, -> { where(status: :approved) }

  def approvable_by_appeal?
    auto_rejected? || appealed?
  end
end
