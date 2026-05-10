class SportTemplate < ApplicationRecord
  belongs_to :district
  has_many :sports
  has_many :sport_commissionerships, dependent: :destroy
  has_many :commissioners, through: :sport_commissionerships, source: :user

  enum :athletic_season, { fall: 0, winter: 1, spring: 2, year_round: 3 }
  enum :gender_config,   { separate: 0, combined: 1 }

  validates :name, :athletic_season, :gender_config, presence: true
  validates :name, uniqueness: { scope: :district_id, case_sensitive: false }

  scope :active, -> { where(active: true) }
end
