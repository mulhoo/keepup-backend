class Invitation < ApplicationRecord
  has_secure_token :token, length: 36

  belongs_to :season
  belongs_to :invited_by, class_name: "User"

  enum :role, { student: 0, parent: 1 }

  validates :email,      presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role,       presence: true
  validates :expires_at, presence: true

  scope :pending,  -> { where(accepted_at: nil).where("expires_at > ?", Time.current) }
  scope :expired,  -> { where(accepted_at: nil).where("expires_at <= ?", Time.current) }
  scope :accepted, -> { where.not(accepted_at: nil) }

  def pending?
    accepted_at.nil? && expires_at > Time.current
  end

  def accepted?
    accepted_at.present?
  end

  def accept!(user)
    update!(accepted_at: Time.current)
  end
end
