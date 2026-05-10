class TeamLevel < ApplicationRecord
  belongs_to :sport
  has_many :seasons, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :sport_id, case_sensitive: false }

  scope :active,   -> { where(active: true) }
  scope :ordered,  -> { order(:display_order, :name) }

  default_scope { order(:display_order, :name) }
end
