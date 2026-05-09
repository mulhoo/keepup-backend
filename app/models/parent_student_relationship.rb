class ParentStudentRelationship < ApplicationRecord
  belongs_to :parent, class_name: "User"
  belongs_to :student, class_name: "User"

  validates :parent_id, uniqueness: { scope: :student_id }
  validate :parent_is_parent_role
  validate :student_is_student_role

  private

  def parent_is_parent_role
    return unless parent
    unless parent.sport_memberships.parent.exists?
      errors.add(:parent, "must have a parent sport membership")
    end
  end

  def student_is_student_role
    return unless student
    unless student.sport_memberships.student.exists?
      errors.add(:student, "must have a student sport membership")
    end
  end
end
