class AccessLog < ApplicationRecord
  belongs_to :accessor, class_name: "User"
  belongs_to :accessed_user, class_name: "User"
  belongs_to :sport, optional: true

  has_one :access_notification, dependent: :destroy

  enum :reason, {
    conduct_concern: 0,
    safety_issue:    1,
    parent_request:  2
  }

  validates :accessor, :accessed_user, :accessor_role, :reason, presence: true

  after_create :create_notification_for_supervisor
  after_create :trigger_anomaly_analysis

  # Gemma4 Call
  def apply_anomaly_result!(score:, flagged:, reason: nil)
    update!(
      anomaly_score: score,
      anomaly_flagged: flagged,
      anomaly_reason: reason
    )
  end

  private

  def create_notification_for_supervisor
    supervisor = NotificationChain.supervisor_for(accessor, sport:)
    return unless supervisor

    AccessNotification.create!(notified_user: supervisor, access_log: self)
  end

  def trigger_anomaly_analysis
    GemmaAccessAnalysisJob.perform_later(id)
  end
end
