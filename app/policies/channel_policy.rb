class ChannelPolicy < ApplicationPolicy
  def show?   = viewable?
  def index?  = true
  def create? = coach_or_admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.active if admin?

      visible_season_ids = coaching_season_ids
      scope.active.where(season_id: visible_season_ids)
    end

    private

    # Athletic directors and school admins see all channels
    def admin?
      user.institution_roles.exists?
    end

    # Head coaches can see all seasons they coach (head or assistant).
    # Assistant-only coaches can only see their assistant_coach seasons.
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
    return true if user.institution_roles.exists?

    sm = user.season_memberships.active.find_by(season: record.season)
    return false unless sm
    return true if sm.head_coach? || sm.assistant_coach?

    # Students and parents see only non-blocked visible channels
    record.viewable_by?(user)
  end

  def coach_or_admin?
    return true if user.institution_roles.exists?

    user.season_memberships.active
        .where(role: %i[head_coach assistant_coach])
        .exists?(season: record.season)
  end
end
