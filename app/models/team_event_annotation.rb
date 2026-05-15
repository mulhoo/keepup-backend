class TeamEventAnnotation < ApplicationRecord
  belongs_to :calendar_event
  belongs_to :season
  belongs_to :updated_by, class_name: "User"

  validates :calendar_event, :season, presence: true
end
