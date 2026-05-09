class Sport < ApplicationRecord
  belongs_to :school

  has_many :coop_authorizations, dependent: :destroy
  has_many :coop_schools, through: :coop_authorizations, source: :school
  has_many :sport_memberships, dependent: :destroy
  has_many :users, through: :sport_memberships
  has_many :channels, dependent: :destroy
  has_many :dm_conversations, dependent: :destroy
  has_many :access_logs, dependent: :destroy

  enum :status, { pending: 0, active: 1, inactive: 2 }

  validates :name, :school, presence: true
  validates :status, presence: true

  scope :active, -> { where(status: :active) }

  # A co-op sport goes active once every school has an approved coop_authorization.
  def all_schools_authorized?
    coop_authorizations.any? && coop_authorizations.all?(&:approved?)
  end

  def activate_if_ready!
    update!(status: :active) if all_schools_authorized?
  end

  def coaches
    sport_memberships.where(role: [:head_coach, :assistant_coach]).includes(:user).map(&:user)
  end

  def students
    sport_memberships.student.includes(:user).map(&:user)
  end

  def head_coaches
    sport_memberships.head_coach.includes(:user).map(&:user)
  end
end
