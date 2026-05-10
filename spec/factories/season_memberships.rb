FactoryBot.define do
  factory :season_membership do
    user
    season
    role   { :student }
    status { :active }

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
