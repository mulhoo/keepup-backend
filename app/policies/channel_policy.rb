class ChannelPolicy < ApplicationPolicy
  def show?   = viewable?
  def index?  = true
  def create? = coach_or_admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      inst_role = user.institution_roles.find_by(
        role: InstitutionRole::MANAGEABLE_BY.keys + [ "super_admin" ]
      )

      if inst_role
        return scope.active if inst_role.super_admin? || inst_role.district_id.present?
        return scope.active.joins(season: { sport: :school })
                           .where(schools: { id: inst_role.school_id })
      end

      scope.active.where(season_id: coaching_season_ids)
    end

    private

    def coaching_season_ids
      memberships = user.season_memberships.active
      if memberships.head_coach.exists?
        memberships.where(role: %i[head_coach assistant_coach]).pluck(:season_id)
      else
        memberships.assistant_coach.pluck(:season_id)
      end
    end
  end

  private

  def viewable?
    inst_role = user.institution_roles.find_by(
      role: InstitutionRole::MANAGEABLE_BY.keys + [ "super_admin" ]
    )
    if inst_role
      return true if inst_role.super_admin? || inst_role.district_id.present?
      return record.season.sport.school_id == inst_role.school_id
    end

    sm = user.season_memberships.active.find_by(season: record.season)
    return false unless sm
    return true if sm.head_coach? || sm.assistant_coach?

    record.viewable_by?(user)
  end

  def coach_or_admin?
    inst_role = user.institution_roles.find_by(
      role: InstitutionRole::MANAGEABLE_BY.keys + [ "super_admin" ]
    )
    if inst_role
      return true if inst_role.super_admin? || inst_role.district_id.present?
      return record.season.sport.school_id == inst_role.school_id
    end

    user.season_memberships.active
        .where(role: %i[head_coach assistant_coach])
        .exists?(season: record.season)
  end
end
