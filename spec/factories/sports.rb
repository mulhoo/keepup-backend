FactoryBot.define do
  factory :sport do
    school
    sport_template
    sport_type { "team" }
    gender     { :coed }
    status     { :pending }

    trait :boys   do; gender { :boys  }; end
    trait :girls  do; gender { :girls }; end
    trait :coed   do; gender { :coed  }; end

    trait :active   do; status { :active   }; end
    trait :inactive do; status { :inactive }; end
  end
end
