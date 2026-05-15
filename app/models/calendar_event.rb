class CalendarEvent < ApplicationRecord
  belongs_to :sport
  belongs_to :created_by, class_name: "User"
  has_many   :team_event_annotations, dependent: :destroy

  enum :event_type, { game: 0, meet: 1, practice: 2, tournament: 3, other: 4 }
  enum :home_away,  { home: 0, away: 1, neutral: 2 }
  enum :status,     { scheduled: 0, cancelled: 1, postponed: 2 }

  validates :title, :starts_at, presence: true

  scope :upcoming,  -> { where("starts_at >= ?", Time.current).order(:starts_at) }
  scope :in_range,  ->(from, to) { where(starts_at: from..to).order(:starts_at) }
end
