class AutoArchiveExpiredRolesJob < ApplicationJob
  queue_as :default

  def perform
    expired_user_ids = InstitutionRole
      .where("end_date IS NOT NULL AND end_date <= ?", Date.current)
      .joins(:user)
      .where(users: { active: true })
      .distinct
      .pluck(:user_id)

    return if expired_user_ids.empty?

    InstitutionRole.where(user_id: expired_user_ids).update_all(active: false)
    User.where(id: expired_user_ids).update_all(active: false, deleted_at: Time.current)

    Rails.logger.info("[AutoArchiveExpiredRolesJob] Archived #{expired_user_ids.size} user(s): #{expired_user_ids.join(', ')}")
  end
end
