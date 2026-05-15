module Admin
  class SportsController < ApplicationController
    before_action :set_sport, only: [ :show, :set_commissioner, :remove_commissioner, :update_levels ]

    def index
      sports = accessible_sports
                 .includes(:sport_template, school: :district,
                            seasons: { season_memberships: :user })
                 .order("sport_templates.name")
      render json: sports.map { |s| serialize(s) }
    end

    def show
      render json: serialize(@sport).merge(members: members_for(@sport))
    end

    def set_commissioner
      require_commissioner_management!
      return if performed?

      user = User.active.find_by(email: params[:email]&.downcase&.strip)
      unless user
        return render json: { error: "No active user found with that email" }, status: :not_found
      end

      @sport.commissioner = user
      render json: serialize(@sport.reload)
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def remove_commissioner
      require_commissioner_management!
      return if performed?

      @sport.commissioner = nil
      render json: serialize(@sport.reload)
    end

    def update_levels
      require_levels_management!
      return if performed?

      levels = Array(params[:levels]).map { |l| l.to_s.strip }.reject(&:blank?).uniq
      @sport.update!(levels: levels)
      render json: serialize(@sport)
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def set_sport
      @sport = accessible_sports
                 .includes(:sport_template, school: :district,
                            seasons: { season_memberships: :user })
                 .find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Sport not found" }, status: :not_found
    end

    def require_commissioner_management!
      role = current_user.institution_roles.find_by(
        role: %w[district_admin school_admin athletic_director super_admin]
      )
      unless role
        render json: { error: "Not authorized to manage commissioners" }, status: :forbidden
      end
    end

    def require_levels_management!
      admin_role = current_user.institution_roles.find_by(
        role: %w[district_admin school_admin athletic_director super_admin]
      )
      return if admin_role

      # Head coaches of this sport's current season may also manage levels
      season = @sport.current_season
      if season&.season_memberships&.exists?(user: current_user, role: :head_coach, status: :active)
        return
      end

      render json: { error: "Not authorized to manage levels" }, status: :forbidden
    end

    def accessible_sports
      inst_role = current_user.institution_roles.find_by(
        role: InstitutionRole::MANAGEABLE_BY.keys + [ "super_admin" ]
      )

      base = Sport.joins(:sport_template, school: :district)

      if inst_role
        return base if inst_role.super_admin?

        if inst_role.district_id.present?
          return base.joins(:school).where(schools: { district_id: inst_role.district_id })
        else
          return base.where(school_id: inst_role.school_id)
        end
      end

      # Coaches see all sports at their school (frontend filters to their own)
      coach_role = current_user.institution_roles.find_by(role: %w[head_coach assistant_coach])
      if coach_role
        return base.where(school_id: coach_role.school_id)
      end

      commissionerships = current_user.sport_commissionerships.active.to_a
      if commissionerships.any?
        placeholders = commissionerships.map { "(districts.id = ? AND sport_templates.id = ?)" }
        values       = commissionerships.flat_map { |c| [ c.district_id, c.sport_template_id ] }
        return base.where(placeholders.join(" OR "), *values)
      end

      Sport.none
    end

    def serialize(sport)
      current = sport.seasons.find(&:active?) || sport.seasons.max_by(&:id)

      coaches = (current&.season_memberships || [])
        .select { |m| (m.head_coach? || m.assistant_coach?) && m.active? }
        .map { |m| { id: m.user_id, first_name: m.user.first_name, last_name: m.user.last_name, role: m.role } }

      athlete_count = (current&.season_memberships || [])
        .count { |m| m.student? && m.active? }

      athletic_season = sport.athletic_season == "year_round" ? "fall" : sport.athletic_season

      default_year = begin
        y = Date.current.month >= 8 ? Date.current.year : Date.current.year - 1
        "#{y}-#{(y + 1).to_s.last(2)}"
      end

      commissioner = sport.commissioner
      {
        id:                sport.id,
        name:              sport.name,
        gender:            sport.gender,
        status:            sport.inactive? ? "completed" : sport.status,
        season:            athletic_season,
        school_year:       current&.school_year || default_year,
        school_id:         sport.school_id,
        school_name:       sport.school.name,
        district_id:       sport.school.district_id,
        sport_template_id: sport.sport_template_id,
        levels:            sport.levels || [],
        athlete_count:,
        coaches:,
        commissioner:      commissioner ? {
          id:         commissioner.id,
          first_name: commissioner.first_name,
          last_name:  commissioner.last_name,
          email:      commissioner.email
        } : nil
      }
    end

    def members_for(sport)
      current = sport.seasons.find(&:active?) || sport.seasons.max_by(&:id)
      return [] unless current

      current.season_memberships.select(&:active?).map do |m|
        role = (m.student? && m.is_captain) ? "student_captain" : m.role
        {
          user_id:       m.user_id,
          first_name:    m.user.first_name,
          last_name:     m.user.last_name,
          role:,
          email:         m.user.email,
          phone:         m.user.phone,
          dob:           m.user.dob,
          jersey_number: m.jersey_number,
          grade:         m.grade,
          level:         m.level,
          position:      m.position,
          is_captain:    m.is_captain
        }
      end
    end
  end
end
