module Admin
  class StaffController < ApplicationController
    def index
      authorize InstitutionRole, policy_class: Admin::StaffPolicy
      roles = policy_scope(InstitutionRole, policy_scope_class: Admin::StaffPolicy::Scope)
      render json: { staff: roles.map { |r| serialize(r) } }
    end

    def create
      role_record = InstitutionRole.new(role: params[:role], school_id: params[:school_id])
      authorize role_record, policy_class: Admin::StaffPolicy

      district = manager_district
      if district&.email_domain.present? && !district.email_domain_matches?(params[:email])
        return render json: { error: "Email must end with @#{district.email_domain}" }, status: :unprocessable_entity
      end

      temp_password = SecureRandom.hex(10)
      user = User.find_or_initialize_by(email: params[:email]&.downcase&.strip)
      user.assign_attributes(
        first_name: params[:first_name],
        last_name:  params[:last_name],
        password:   temp_password,
        active:     true
      )

      unless user.save
        return render json: { error: user.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end

      unless params[:start_date].present?
        return render json: { error: "Start date is required" }, status: :unprocessable_entity
      end

      role_record.user       = user
      role_record.start_date = params[:start_date]
      unless role_record.save
        return render json: { error: role_record.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end

      render json: serialize(role_record).merge(temp_password:), status: :created
    end

    def update
      role_record = InstitutionRole.find(params[:id])
      authorize role_record, policy_class: Admin::StaffPolicy

      district = manager_district
      if params[:email].present? && district&.email_domain.present? && !district.email_domain_matches?(params[:email])
        return render json: { error: "Email must end with @#{district.email_domain}" }, status: :unprocessable_entity
      end

      user = role_record.user
      user_attrs = params.permit(:first_name, :last_name, :email).to_h.compact
      unless user.update(user_attrs)
        return render json: { error: user.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end

      role_attrs = {}
      role_attrs[:start_date] = params[:start_date] if params[:start_date].present?
      role_attrs[:end_date]   = params[:end_date].presence if params.key?(:end_date)
      role_record.update!(role_attrs) if role_attrs.any?

      render json: serialize(role_record.reload)
    end

    def destroy
      role_record = InstitutionRole.find(params[:id])
      authorize role_record, policy_class: Admin::StaffPolicy

      role_record.update_columns(end_date: Date.current) if role_record.end_date.nil?
      role_record.user.soft_delete!
      head :no_content
    end

    def restore
      role_record = InstitutionRole.find(params[:id])
      authorize role_record, policy_class: Admin::StaffPolicy

      role_record.user.restore!
      render json: serialize(role_record.reload)
    end

    def assign_sport
      role_record = InstitutionRole.find(params[:id])
      authorize role_record, policy_class: Admin::StaffPolicy

      unless role_record.head_coach? || role_record.assistant_coach?
        return render json: { error: "Only coaches can be assigned to sports" }, status: :unprocessable_entity
      end

      sport = Sport.active.where(school_id: role_record.school_id).find_by(id: params[:sport_id])
      return render json: { error: "Sport not found" }, status: :not_found unless sport

      season = sport.seasons.find(&:active?) || sport.seasons.order(id: :desc).first
      return render json: { error: "Sport has no season" }, status: :unprocessable_entity unless season

      membership = SeasonMembership.find_or_initialize_by(user: role_record.user, season: season)
      membership.update!(role: role_record.role, status: :active)

      render json: serialize(role_record.reload)
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def manager_district
      role = current_user.institution_roles.find_by(role: InstitutionRole::MANAGEABLE_BY.keys)
      return nil unless role
      role.district || role.school&.district
    end

    def serialize(role_record)
      u = role_record.user
      {
        id:          role_record.id,
        user_id:     u.id,
        first_name:  u.first_name,
        last_name:   u.last_name,
        email:       u.email,
        role:        role_record.role,
        school_id:   role_record.school_id,
        school_name: role_record.school&.name,
        active:      u.active,
        start_date:  role_record.start_date.iso8601,
        end_date:    role_record.end_date&.iso8601
      }
    end
  end
end
