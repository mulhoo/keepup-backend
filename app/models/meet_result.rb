class MeetResult < ApplicationRecord
  belongs_to :sport
  belongs_to :home_school, class_name: "School"
  belongs_to :away_school, class_name: "School", optional: true
  belongs_to :uploaded_by, class_name: "User", optional: true
  has_many   :qualification_flags, dependent: :destroy

  def events
    JSON.parse(events_json)
  rescue JSON::ParserError
    []
  end

  def events=(val)
    self.events_json = val.to_json
  end

  def ai_standouts
    JSON.parse(ai_standouts_json)
  rescue JSON::ParserError
    []
  end

  def ai_standouts=(val)
    self.ai_standouts_json = val.to_json
  end
end
