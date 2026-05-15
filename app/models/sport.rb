class Sport < ApplicationRecord
  belongs_to :school
  belongs_to :sport_template

  has_many :coop_authorizations, dependent: :destroy
  has_many :coop_schools, through: :coop_authorizations, source: :school
  has_many :seasons, dependent: :destroy
  has_many :season_memberships, through: :seasons
  has_many :users, through: :season_memberships
  has_many :sport_emojis, dependent: :destroy
  has_many :access_logs, dependent: :destroy
  has_many :calendar_events, dependent: :destroy

  enum :status, { pending: 0, active: 1, inactive: 2 }
  enum :gender,  { boys: 0, girls: 1, coed: 2 }

  delegate :athletic_season, :fall?, :winter?, :spring?, :year_round?, to: :sport_template

  validates :school, :sport_template, :status, presence: true

  scope :active, -> { where(status: :active) }

  def name
    return sport_template.name if sport_template.combined?

    "#{gender.to_s.capitalize} #{sport_template.name}"
  end

  def all_schools_authorized?
    coop_authorizations.any? && coop_authorizations.all?(&:approved?)
  end

  def activate_if_ready!
    update!(status: :active) if all_schools_authorized?
  end

  def current_season
    seasons.active.order(starts_at: :desc).first
  end

  def commissioner
    sport_template.sport_commissionerships
                  .active
                  .find_by(district: school.district)
                  &.user
  end

  def commissioner=(user)
    c = sport_template.sport_commissionerships.find_or_initialize_by(district: school.district)
    if user
      c.assign_attributes(user: user, status: :active)
      c.save!
    else
      c.update!(status: :inactive) if c.persisted?
    end
  end
end
