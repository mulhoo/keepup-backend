class ActivityPolicy < ApplicationPolicy
  def index?                   = true
  def notify_parents?          = flagged_event? && (admin? || head_coach?)
  def notify_ad?               = flagged_event? && head_coach? && !admin?
  def notify_district_admin?   = flagged_event? && school_level_institution_role?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if admin?
        school = user.institution_roles.first&.school
        return scope.none unless school
        scope.for_school(school).recent
      else
        ids = coaching_season_ids
        return scope.none if ids.empty?
        scope.message_flagged.for_seasons(ids).recent
      end
    end

    private

    def admin?
      user.institution_roles.exists?
    end

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

  def flagged_event?
    record.event_type == "message_flagged"
  end

  def admin?
    user.institution_roles.exists?
  end

  def head_coach?
    user.season_memberships.active.find_by(season: record.season)&.head_coach?
  end

  # Only school-level roles (AD, school admin) — not coaches, not district admins
  def school_level_institution_role?
    school = record.season&.school
    return false unless school
    user.institution_roles.where(school:, role: [ :athletic_director, :school_admin ]).exists?
  end
end
