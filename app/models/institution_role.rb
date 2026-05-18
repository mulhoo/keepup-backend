class InstitutionRole < ApplicationRecord
  belongs_to :user
  belongs_to :district, optional: true
  belongs_to :school, optional: true

  enum :role, {
    district_admin:    0,
    school_admin:      1,
    athletic_director: 2,
    dpa_contact:       3,
    super_admin:       4,
    head_coach:        5,
    assistant_coach:   6
  }

  # Roles that represent operational staff at a school (not season-specific)
  SCHOOL_STAFF_ROLES = %w[school_admin athletic_director head_coach assistant_coach].freeze

  # What each manager role is allowed to create/edit/remove
  MANAGEABLE_BY = {
    "district_admin"    => %w[school_admin athletic_director head_coach assistant_coach],
    "school_admin"      => %w[athletic_director head_coach assistant_coach],
    "athletic_director" => %w[head_coach assistant_coach]
  }.freeze

  before_create -> { self.start_date ||= Date.current }

  validates :role, presence: true
  validate :scope_presence

  scope :active,       -> { all }
  scope :for_district, ->(district) { where(district:) }
  scope :for_school,   ->(school)   { where(school:) }
  scope :staff,        -> { where(role: SCHOOL_STAFF_ROLES) }

  private

  def scope_presence
    return if super_admin?

    if district_id.present? && school_id.present?
      errors.add(:base, "cannot be scoped to both a district and a school")
    elsif district_id.blank? && school_id.blank?
      errors.add(:base, "must be scoped to a district or a school")
    end

    if district_admin? || dpa_contact?
      errors.add(:district, "is required for #{role}") if district_id.blank?
    elsif school_admin? || athletic_director? || head_coach? || assistant_coach?
      errors.add(:school, "is required for #{role}") if school_id.blank?
    end
  end
end
