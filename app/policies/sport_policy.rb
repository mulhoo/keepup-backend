class SportPolicy < ApplicationPolicy
  def index? = true

  def show?
    return true if super_admin? || school_admin_for_sport?
    user.season_memberships.active.joins(:season).where(seasons: { sport_id: record.id }).exists?
  end

  # Creating and updating sports is a school-level admin or super_admin action
  def create?  = school_admin_for_sport? || super_admin?
  def update?  = school_admin_for_sport? || super_admin?
  def destroy? = super_admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if super_admin?

      if school_level_admin?
        school_ids = user.institution_roles.where.not(school_id: nil).pluck(:school_id)
        scope.where(school_id: school_ids)
      elsif district_admin?
        district_ids = user.institution_roles.district_admin.pluck(:district_id)
        school_ids = School.where(district_id: district_ids).pluck(:id)
        scope.where(school_id: school_ids)
      else
        sport_ids = user.season_memberships.active
                        .joins(:season)
                        .pluck("seasons.sport_id")
                        .uniq
        scope.where(id: sport_ids)
      end
    end

    private

    def super_admin?
      user.institution_roles.super_admin.exists?
    end

    def school_level_admin?
      user.institution_roles.where(role: %i[athletic_director school_admin]).exists?
    end

    def district_admin?
      user.institution_roles.district_admin.exists?
    end
  end

  private

  def school_admin_for_sport?
    user.institution_roles
        .where(school: record.school, role: %i[athletic_director school_admin])
        .exists?
  end

  def super_admin?
    user.institution_roles.super_admin.exists?
  end
end
