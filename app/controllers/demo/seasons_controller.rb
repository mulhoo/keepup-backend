module Demo
  class SeasonsController < Demo::ApplicationController
    include DemoGuard
    before_action :require_demo_mode

    def index
      if (school = ad_school)
        seasons = Season.joins(sport: :school)
                        .where(sports: { school_id: school.id })
                        .where(school_year: current_school_year)
                        .active
                        .includes(sport: :school)
        render json: seasons.map { |s| serialize_season(s, "athletic_director") }
      else
        memberships = current_user.season_memberships
                                  .active
                                  .joins(:season).merge(Season.active.where(school_year: current_school_year))
                                  .includes(season: { sport: :school })
                                  .order(created_at: :desc)
        render json: memberships.map { |sm| serialize_season(sm.season, sm.role) }
      end
    end

    private

    def serialize_season(season, role)
      sport  = season.sport
      school = sport.school
      {
        id:          season.id,
        name:        season.name,
        sport:       sport.name,
        school_year: season.school_year,
        status:      season.status,
        role:        role,
        school:      { id: school.id, name: school.name }
      }
    end
  end
end
