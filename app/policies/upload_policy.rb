class UploadPolicy < ApplicationPolicy
  # record is the resource being uploaded to (School, User, or Sport)

  def school_icon?   = school_admin_for_school?
  def school_banner? = school_admin_for_school?

  # Users may only update their own profile photo
  def profile_photo?
    record.is_a?(User) && record.id == user.id
  end

  # Any active coach of the sport may upload sport images
  def sport_emoji?   = coach_for_sport?
  def sport_banner?  = coach_for_sport?

  private

  def coach_for_sport?
    record.is_a?(Sport) &&
      user.season_memberships.active
          .joins(:season)
          .where(seasons: { sport_id: record.id }, role: %i[head_coach assistant_coach])
          .exists?
  end

  private

  def school_admin_for_school?
    record.is_a?(School) &&
      user.institution_roles
          .where(school: record, role: %i[athletic_director school_admin])
          .exists?
  end
end
