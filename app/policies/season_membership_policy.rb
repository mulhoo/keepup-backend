class SeasonMembershipPolicy < ApplicationPolicy
  # Anyone can trigger an index; Scope narrows what they see
  def index?   = true
  def show?    = member_of_season? || school_admin?

  # Only the head coach of that specific season, or a school-level admin, may
  # add, edit, or remove roster entries. Assistant coaches cannot.
  def create?  = head_coach_of_season? || school_admin?
  def update?  = head_coach_of_season? || school_admin?
  def destroy? = head_coach_of_season? || school_admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if school_level_admin?
        school_ids = user.institution_roles.where.not(school_id: nil).pluck(:school_id)
        scope.active.joins(season: :sport).where(sports: { school_id: school_ids })
      elsif district_admin?
        district_ids = user.institution_roles.district_admin.pluck(:district_id)
        scope.active.joins(season: { sport: :school }).where(schools: { district_id: district_ids })
      else
        coached_season_ids = user.season_memberships.active
                                 .where(role: %i[head_coach assistant_coach])
                                 .pluck(:season_id)
        scope.active.where(season_id: coached_season_ids)
      end
    end

    private

    def school_level_admin?
      user.institution_roles.where(role: %i[athletic_director school_admin]).exists?
    end

    def district_admin?
      user.institution_roles.district_admin.exists?
    end
  end

  private

  def head_coach_of_season?
    user.season_memberships.active.find_by(season: record.season)&.head_coach?
  end

  def school_admin?
    school = record.season&.school
    return false unless school
    user.institution_roles.where(school:, role: %i[athletic_director school_admin]).exists?
  end

  def member_of_season?
    user.season_memberships.active.exists?(season: record.season)
  end
end
