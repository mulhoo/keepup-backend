class SportMembership < ApplicationRecord
  belongs_to :user
  belongs_to :sport
  belongs_to :school

  enum :role, {
    head_coach:      0,
    assistant_coach: 1,
    student:         2,
    parent:          3
  }

  validates :user, :sport, :school, :role, presence: true
  validates :user_id, uniqueness: { scope: :sport_id, message: "is already a member of this sport" }

  validate :captain_only_for_students

  scope :active, -> { where(active: true) }
  scope :coaches, -> { where(role: [:head_coach, :assistant_coach]) }
  scope :captains, -> { where(role: :student, is_captain: true) }

  def deactivate!
    update!(active: false, left_date: Date.current)
  end

  private

  def captain_only_for_students
    errors.add(:is_captain, "can only be set for students") if is_captain? && !student?
  end
end
