FactoryBot.define do
  factory :coop_authorization do
    sport
    school
    status { :pending }

    trait :approved do
      status      { :approved }
      approved_at { Time.current }
    end

    trait :revoked do
      status     { :revoked }
      revoked_at { Time.current }
    end
  end
end
