class SportCommissionership < ApplicationRecord
  belongs_to :user
  belongs_to :sport_template
  belongs_to :district
  belongs_to :assigned_by, class_name: "User", optional: true

  enum :status, { active: 0, inactive: 1 }

  validates :user_id, uniqueness: { scope: [:sport_template_id, :district_id] }
  validates :status, presence: true

  scope :active, -> { where(status: :active) }

  def assign!(assigner)
    update!(assigned_by: assigner, assigned_at: Time.current, status: :active)
  end
end
