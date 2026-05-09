FactoryBot.define do
  factory :sport_membership do
    user
    sport
    school { sport.school }
    role   { :student }
    active { true }

    trait :head_coach do
      role { :head_coach }
    end

    trait :assistant_coach do
      role { :assistant_coach }
    end

    trait :student do
      role { :student }
    end

    trait :parent do
      role { :parent }
    end

    trait :captain do
      role       { :student }
      is_captain { true }
    end
  end
end
