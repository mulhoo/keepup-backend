class User < ApplicationRecord
  has_secure_password validations: false

  has_many :institution_roles, dependent: :destroy
  has_many :sport_memberships, dependent: :destroy
  has_many :sports, through: :sport_memberships

  has_many :parent_relationships,
           class_name: "ParentStudentRelationship",
           foreign_key: :parent_id,
           dependent: :destroy
  has_many :student_relationships,
           class_name: "ParentStudentRelationship",
           foreign_key: :student_id,
           dependent: :destroy
  has_many :children, through: :parent_relationships, source: :student
  has_many :parents, through: :student_relationships, source: :parent

  has_many :created_channels, class_name: "Channel", foreign_key: :created_by_id
  has_many :channel_memberships, dependent: :destroy
  has_many :channels, through: :channel_memberships

  has_many :sent_messages, class_name: "Message", foreign_key: :sender_id
  has_many :reactions, dependent: :destroy

  has_many :sent_direct_messages, class_name: "DirectMessage", foreign_key: :sender_id

  has_many :access_logs_as_accessor,
           class_name: "AccessLog",
           foreign_key: :accessor_id
  has_many :access_logs_as_subject,
           class_name: "AccessLog",
           foreign_key: :accessed_user_id

  has_many :device_tokens, dependent: :destroy
  has_many :noticed_notifications, class_name: "Noticed::Notification", as: :recipient, dependent: :destroy

  belongs_to :theme, optional: true

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :theme_available_to_user, if: :theme_id?
  validates :first_name, :last_name, presence: true
  validates :password, length: { minimum: 8 }, allow_blank: true

  before_validation :normalize_email

  scope :active, -> { where(active: true, deleted_at: nil) }

  def full_name
    "#{first_name} #{last_name}"
  end

  def effective_theme
    theme || Theme.find_by(scope: :system, name: "Default Dark")
  end

  def soft_delete!
    update!(active: false, deleted_at: Time.current)
  end

  def sport_role(sport)
    sport_memberships.find_by(sport:)&.role
  end

  def coach_of?(sport)
    sm = sport_memberships.find_by(sport:)
    sm&.head_coach? || sm&.assistant_coach?
  end

  def head_coach_of?(sport)
    sport_memberships.find_by(sport:)&.head_coach?
  end

  def student_of?(sport)
    sport_memberships.find_by(sport:)&.student?
  end

  def parent_in?(sport)
    sport_memberships.find_by(sport:)&.parent?
  end

  private

  def normalize_email
    self.email = email&.downcase&.strip
  end

  def theme_available_to_user
    return if theme.system?

    user_school_ids = sport_memberships.active.pluck(:school_id).to_set
    unless user_school_ids.include?(theme.school_id)
      errors.add(:theme, "is not available at your school")
    end
  end
end
