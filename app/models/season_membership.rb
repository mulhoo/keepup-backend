class SeasonMembership < ApplicationRecord
  belongs_to :user
  belongs_to :season

  enum :role, {
    head_coach:      0,
    assistant_coach: 1,
    student:         2,
    parent:          3
  }

  enum :status, { active: 0, removed: 1, archived: 2 }

  validates :user, :season, :role, presence: true
  validates :user_id, uniqueness: { scope: :season_id, message: "is already a member of this season" }
  validate  :captain_only_for_students

  scope :active,   -> { where(status: :active) }
  scope :coaches,  -> { where(role: %i[head_coach assistant_coach]) }
  scope :captains, -> { where(role: :student, is_captain: true) }

  def remove!
    update!(status: :removed, removed_at: Time.current)
  end

  private

  def captain_only_for_students
    errors.add(:is_captain, "can only be set for students") if is_captain? && !student?
  end
end
