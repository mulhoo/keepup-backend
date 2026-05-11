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

      user = User.find_or_initialize_by(email: params[:email]&.downcase&.strip)
      user.assign_attributes(
        first_name: params[:first_name],
        last_name:  params[:last_name],
        password:   params[:password].presence || SecureRandom.hex(10),
        active:     true
      )

      unless user.save
        return render json: { error: user.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end

      role_record.user = user
      unless role_record.save
        return render json: { error: role_record.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end

      render json: serialize(role_record), status: :created
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

      render json: serialize(role_record.reload)
    end

    def destroy
      role_record = InstitutionRole.find(params[:id])
      authorize role_record, policy_class: Admin::StaffPolicy

      role_record.user.soft_delete!
      head :no_content
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
        active:      u.active
      }
    end
  end
end
