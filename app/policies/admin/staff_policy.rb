module Admin
  class StaffPolicy < ApplicationPolicy
    # record is an InstitutionRole

    def index?   = managing_role.present?
    def create?  = can_manage?(record.role)
    def update?  = can_manage?(record.role)
    def destroy? = can_manage?(record.role)

    class Scope < ApplicationPolicy::Scope
      def resolve
        role = managing_role
        return scope.none unless role

        manageable = InstitutionRole::MANAGEABLE_BY[role.role] || []

        if role.district_admin?
          scope.includes(:user, :school)
               .joins(:school).where(schools: { district_id: role.district_id })
               .where(role: manageable)
               .or(
                 scope.includes(:user, :school)
                      .where(district_id: role.district_id, role: manageable)
               )
        else
          scope.includes(:user, :school)
               .where(school_id: role.school_id, role: manageable)
        end
      end
    end

    private

    def can_manage?(target_role)
      role = managing_role
      return false unless role
      (InstitutionRole::MANAGEABLE_BY[role.role] || []).include?(target_role.to_s)
    end

    def managing_role
      user.institution_roles.find_by(role: InstitutionRole::MANAGEABLE_BY.keys)
    end
  end
end
