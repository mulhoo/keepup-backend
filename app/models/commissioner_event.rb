class CommissionerEvent < ApplicationRecord
  belongs_to :sport_template
  belongs_to :district

  def teams
    JSON.parse(teams_json)
  rescue JSON::ParserError
    []
  end

  def teams=(val)
    self.teams_json = val.to_json
  end

  def matchup_pairs
    JSON.parse(matchup_pairs_json)
  rescue JSON::ParserError
    []
  end

  def matchup_pairs=(val)
    self.matchup_pairs_json = val.to_json
  end
end
