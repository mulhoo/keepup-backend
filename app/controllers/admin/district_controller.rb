module Admin
  class DistrictController < ApplicationController
    before_action :require_district_admin

    def show
      render json: serialize(manager_district)
    end

    def update
      district = manager_district
      unless district.update(params.permit(:email_domain))
        return render json: { error: district.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
      render json: serialize(district)
    end

    private

    def require_district_admin
      unless current_user.institution_roles.district_admin.exists?
        render json: { error: "Not authorized" }, status: :forbidden
      end
    end

    def manager_district
      current_user.institution_roles.district_admin.first&.district
    end

    def serialize(district)
      {
        id:           district.id,
        name:         district.name,
        email_domain: district.email_domain
      }
    end
  end
end
