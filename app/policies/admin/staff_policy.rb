module Admin
  class StaffPolicy < ApplicationPolicy
    # record is an InstitutionRole

    def index?   = managing_role.present?
    def create?  = can_manage?(record.role)
    def update?  = can_manage?(record.role)
    def destroy? = can_manage?(record.role)
    def restore? = can_manage?(record.role)

    class Scope < ApplicationPolicy::Scope
      def resolve
        role = managing_role
        return scope.none unless role

        manageable = InstitutionRole::MANAGEABLE_BY[role.role] || []

        if role.district_admin?
          school_ids = role.district.school_ids
          scope.includes(:user, :school)
               .where(role: manageable, school_id: school_ids)
               .or(
                 scope.includes(:user, :school)
                      .where(role: manageable, district_id: role.district_id)
               )
        else
          scope.includes(:user, :school)
               .where(school_id: role.school_id, role: manageable)
        end
      end

      private

      def managing_role
        user.institution_roles.find_by(role: InstitutionRole::MANAGEABLE_BY.keys)
      end
    end

    private

    def can_manage?(target_role)
      role = managing_role
      return false unless role
      return false unless (InstitutionRole::MANAGEABLE_BY[role.role] || []).include?(target_role.to_s)
      in_scope?(role)
    end

    def in_scope?(managing)
      if managing.district_admin?
        record.school&.district_id == managing.district_id ||
          record.district_id == managing.district_id
      else
        record.school_id == managing.school_id
      end
    end

    def managing_role
      user.institution_roles.find_by(role: InstitutionRole::MANAGEABLE_BY.keys)
    end
  end
end
