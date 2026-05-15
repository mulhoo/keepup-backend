class Venue < ApplicationRecord
  belongs_to :school, optional: true

  def availability
    JSON.parse(availability_json)
  rescue JSON::ParserError
    []
  end

  def availability=(val)
    self.availability_json = val.to_json
  end
end
