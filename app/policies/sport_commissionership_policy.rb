class SportCommissionershipPolicy < ApplicationPolicy
  def index?  = super_admin?
  def create? = super_admin?
  def update? = super_admin?
  def destroy? = super_admin?

  # Commissioners can view their own assignments
  def show?
    super_admin? || own_commissionership?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if super_admin?

      scope.where(user: user).active
    end

    private

    def super_admin?
      user.institution_roles.super_admin.exists?
    end
  end

  private

  def super_admin?
    user.institution_roles.super_admin.exists?
  end

  def own_commissionership?
    record.user_id == user.id
  end
end
