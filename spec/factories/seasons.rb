FactoryBot.define do
  factory :season do
    association :team_level
    sport       { team_level.sport }
    name        { "#{sport.name} 2025-26" }
    school_year { "2025-26" }
    starts_at   { Date.new(2025, 10, 15) }
    ends_at     { Date.new(2026, 3, 15) }
    status      { :active }
  end
end
