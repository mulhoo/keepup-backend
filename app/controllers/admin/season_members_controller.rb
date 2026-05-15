module Admin
  class SeasonMembersController < ApplicationController
    before_action :set_sport

    def update
      membership = current_season_membership
      return render json: { error: "Member not found" }, status: :not_found unless membership

      unless can_manage?(membership)
        return render json: { error: "Forbidden" }, status: :forbidden
      end

      ActiveRecord::Base.transaction do
        membership.update!(membership_attrs)
        membership.user.update!(user_attrs) if user_attrs.any?
      end

      render json: serialize(membership.reload)
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def set_sport
      @sport = Sport.active.find_by(id: params[:sport_id])
      render json: { error: "Sport not found" }, status: :not_found unless @sport
    end

    def current_season_membership
      season = @sport.seasons.order(id: :desc).first
      return nil unless season

      season.season_memberships.active.find_by(user_id: params[:user_id])
    end

    def can_manage?(membership)
      is_head_coach = current_user.season_memberships.active
                                  .where(role: :head_coach, season: membership.season)
                                  .exists?
      is_head_coach || admin_for?(@sport)
    end

    def admin_for?(sport)
      current_user.institution_roles.exists?(
        role:      %w[super_admin district_admin school_admin athletic_director],
        school_id: [ sport.school_id, nil ]
      )
    end

    def membership_attrs
      params.permit(:jersey_number, :grade, :level, :position, :is_captain).to_h.compact
    end

    def user_attrs
      params.permit(:dob).to_h.compact
    end

    def serialize(m)
      role = (m.student? && m.is_captain) ? "student_captain" : m.role
      {
        user_id:       m.user_id,
        first_name:    m.user.first_name,
        last_name:     m.user.last_name,
        email:         m.user.email,
        phone:         m.user.phone,
        dob:           m.user.dob,
        role:,
        jersey_number: m.jersey_number,
        grade:         m.grade,
        level:         m.level,
        position:      m.position,
        is_captain:    m.is_captain
      }
    end
  end
end
