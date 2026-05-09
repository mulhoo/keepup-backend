class InstitutionRole < ApplicationRecord
  belongs_to :user
  belongs_to :district, optional: true
  belongs_to :school, optional: true

  enum :role, {
    district_admin:   0,
    school_admin:     1,
    athletic_director: 2,
    dpa_contact:      3
  }

  validates :role, presence: true
  validate :scope_presence

  scope :active,       -> { all }
  scope :for_district, ->(district) { where(district:) }
  scope :for_school, ->(school)     { where(school:) }

  private

  def scope_presence
    if district_id.present? && school_id.present?
      errors.add(:base, "cannot be scoped to both a district and a school")
    elsif district_id.blank? && school_id.blank?
      errors.add(:base, "must be scoped to a district or a school")
    end

    if district_admin? || dpa_contact?
      errors.add(:district, "is required for #{role}") if district_id.blank?
    elsif school_admin? || athletic_director?
      errors.add(:school, "is required for #{role}") if school_id.blank?
    end
  end
end
