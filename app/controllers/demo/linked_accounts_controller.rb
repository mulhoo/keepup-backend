module Demo
  class LinkedAccountsController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode

    def index
      memberships = current_user.season_memberships.active
        .where(role: %w[head_coach assistant_coach])
        .joins(season: { sport: :school })
        .includes(:season, season: { sport: :school })

      primary_school_id = primary_school&.id

      linked = memberships
        .select { |sm| sm.season.sport.school_id != primary_school_id }
        .map { |sm| serialize(sm) }

      render json: linked
    end

    def pending
      render json: []
    end

    private

    def primary_school
      @primary_school ||=
        current_user.institution_roles.first&.school ||
        current_user.season_memberships.active
          .where(role: %w[head_coach assistant_coach])
          .joins(season: { sport: :school })
          .order(:created_at)
          .first&.season&.sport&.school
    end

    def serialize(sm)
      sport  = sm.season.sport
      school = sport.school

      {
        id:           sm.id,
        first_name:   current_user.first_name,
        last_name:    current_user.last_name,
        email:        current_user.email,
        school_name:  school.name,
        school_id:    school.id,
        district_name: school.district.name,
        role:         sm.role,
        status:       "accepted",
        linked_at:    sm.created_at.iso8601,
        active_sports: [ {
          id:           sport.id,
          name:         sport.name,
          school_id:    school.id,
          school_name:  school.name,
          season:       sm.season.athletic_season,
          school_year:  sm.season.school_year,
          status:       "active",
          commissioner: nil,
          athlete_count: sm.season.season_memberships.active.student.count,
          coaches:       coaches_for(sm.season),
          coach_role:    sm.role
        } ]
      }
    end

    def coaches_for(season)
      season.season_memberships.active
        .where(role: %w[head_coach assistant_coach])
        .includes(:user)
        .map { |c| { id: c.user_id, first_name: c.user.first_name, last_name: c.user.last_name, role: c.role } }
    end
  end
end
