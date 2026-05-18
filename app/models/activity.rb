class Activity < ApplicationRecord
  belongs_to :actor, class_name: "User", optional: true
  belongs_to :subject, polymorphic: true, optional: true
  belongs_to :season, optional: true
  belongs_to :school, optional: true

  enum :event_type, { message_flagged: 0, data_accessed: 1, safety_accessed: 2, safety_exited: 3, chat_searched: 4, parent_coach_concern: 5 }

  validates :event_type, :occurred_at, presence: true

  scope :recent,      -> { order(occurred_at: :desc) }
  scope :for_school,  ->(school) { where(school:) }
  scope :for_seasons, ->(ids)    { where(season_id: ids) }
end
