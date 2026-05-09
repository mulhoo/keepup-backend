FactoryBot.define do
  factory :sport do
    school
    name       { Faker::Sport.sport }
    sport_type { "team" }
    season     { "2025-26" }
    status     { :pending }

    trait :active do
      status { :active }
    end

    trait :inactive do
      status { :inactive }
    end
  end
end
