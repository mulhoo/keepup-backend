class Season < ApplicationRecord
  belongs_to :sport
  belongs_to :team_level
  belongs_to :archived_by, class_name: "User", optional: true

  has_many :season_memberships, dependent: :destroy
  has_many :users, through: :season_memberships
  has_many :channels, dependent: :destroy
  has_many :dm_conversations, dependent: :destroy

  enum :status, { active: 0, archived: 1, pending: 2 }

  validates :name, :school_year, presence: true
  validates :team_level_id, uniqueness: { scope: :school_year }

  scope :active,   -> { where(status: :active) }
  scope :archived, -> { where(status: :archived) }

  def school
    sport.school
  end

  def athletic_season
    sport.athletic_season
  end

  def level
    team_level.name
  end

  def head_coaches
    season_memberships.head_coach.includes(:user).map(&:user)
  end

  def coaches
    season_memberships.where(role: %i[head_coach assistant_coach]).includes(:user).map(&:user)
  end

  def students
    season_memberships.student.includes(:user).map(&:user)
  end

  def archive!(by:)
    transaction do
      update!(status: :archived, archived_at: Time.current, archived_by: by)
      season_memberships.active.update_all(status: SeasonMembership.statuses[:archived])
      channels.update_all(active: false)
    end
  end
end
