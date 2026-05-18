module Demo
  class SchoolsController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode

    def index
      schools = visible_schools.map { |s| serialize(s) }
      render json: schools
    end

    def show
      school = visible_schools.find_by(id: params[:id])
      return render json: { error: "Not found" }, status: :not_found unless school

      render json: serialize(school)
    end

    private

    def visible_schools
      roles = current_user.institution_roles.to_a

      if roles.any?(&:super_admin?)
        School.active.order(:name)
      elsif roles.any?(&:district_admin?)
        district_ids = roles.select(&:district_admin?).map(&:district_id)
        School.active.where(district_id: district_ids).order(:name)
      else
        school_ids  = roles.filter_map(&:school_id)
        school_ids += current_user.season_memberships.active
                        .joins(season: :sport)
                        .pluck("sports.school_id")
        School.active.where(id: school_ids.uniq).order(:name)
      end
    end

    def serialize(school)
      principal = staff_for(school, %w[school_admin])
      ad        = staff_for(school, %w[athletic_director])

      {
        id:               school.id,
        name:             school.name,
        district_id:      school.district_id,
        district_name:    school.district.name,
        sport_count:      Sport.active.where(school: school).count,
        member_count:     SeasonMembership.active.joins(season: :sport)
                            .where(sports: { school: school }).distinct.count(:user_id),
        principal:        principal ? { first_name: principal.first_name, last_name: principal.last_name, email: principal.email } : nil,
        athletic_director: ad ? { first_name: ad.first_name, last_name: ad.last_name, email: ad.email } : nil,
      }
    end

    def staff_for(school, roles)
      InstitutionRole.joins(:user)
        .where(school: school, role: roles)
        .order(:created_at)
        .first&.user
    end
  end
end
