class User < ApplicationRecord
  has_secure_password validations: false

  has_many :institution_roles, dependent: :destroy
  has_many :sport_commissionerships, dependent: :destroy
  has_many :assigned_commissionerships,
           class_name: "SportCommissionership",
           foreign_key: :assigned_by_id,
           dependent: :nullify
  has_many :season_memberships, dependent: :destroy
  has_many :seasons, through: :season_memberships
  has_many :sports, through: :seasons

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

  store_accessor :accessibility, :font_size
  validates :font_size, inclusion: { in: %w[small medium large] }, allow_nil: true
  before_validation { self.font_size = nil if font_size == "default" }

  store_accessor :preferences, :default_district_key

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :theme_available_to_user, if: :theme_id?
  validates :first_name, :last_name, presence: true
  validates :password, length: { minimum: 8 }, allow_blank: true
  validates :preferred_language,
            inclusion: { in: Gemma::Translator::SUPPORTED_LANGUAGES.keys, allow_nil: true }

  before_validation :normalize_email

  scope :active, -> { where(active: true, deleted_at: nil) }

  def full_name
    "#{first_name} #{last_name}"
  end

  def effective_theme
    theme || Theme.find_by(scope: :system, name: "Default Dark")
  end

  def soft_delete!
    update_columns(active: false, deleted_at: Time.current)
  end

  def restore!
    update_columns(active: true, deleted_at: nil)
  end

  def season_role(season)
    season_memberships.find_by(season:)&.role
  end

  def coach_of_season?(season)
    sm = season_memberships.find_by(season:)
    sm&.head_coach? || sm&.assistant_coach?
  end

  def head_coach_of_season?(season)
    season_memberships.find_by(season:)&.head_coach?
  end

  def student_of_season?(season)
    season_memberships.find_by(season:)&.student?
  end

  def parent_in_season?(season)
    season_memberships.find_by(season:)&.parent?
  end

  private

  def normalize_email
    self.email = email&.downcase&.strip
  end

  def theme_available_to_user
    return if theme.system?

    user_school_ids = season_memberships.active.joins(season: :sport).pluck("sports.school_id").to_set
    unless user_school_ids.include?(theme.school_id)
      errors.add(:theme, "is not available at your school")
    end
  end
end
