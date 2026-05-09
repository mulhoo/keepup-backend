class CoopAuthorization < ApplicationRecord
  belongs_to :sport
  belongs_to :school
  belongs_to :athletic_director, class_name: "User", optional: true

  enum :status, { pending: 0, approved: 1, revoked: 2 }

  validates :sport, :school, presence: true

  after_save :maybe_activate_sport
  after_save :notify_other_ads_on_revocation, if: -> { saved_change_to_status? && revoked? }

  def approve!(ad)
    update!(status: :approved, athletic_director: ad, approved_at: Time.current)
  end

  def revoke!(ad)
    update!(status: :revoked, athletic_director: ad, revoked_at: Time.current)
  end

  private

  def maybe_activate_sport
    sport.activate_if_ready! if approved?
  end

  def notify_other_ads_on_revocation
    # Notify all other ADs associated with this sport that a school has revoked.
    # Notification delivery handled by a background job in production.
    other_school_ids = sport.coop_authorizations.where.not(school_id:).pluck(:school_id)
    other_ads = InstitutionRole.athletic_director
                               .where(school_id: other_school_ids)
                               .includes(:user)
                               .map(&:user)
    # TODO: enqueue RevocationNotificationJob for each AD
  end
end
