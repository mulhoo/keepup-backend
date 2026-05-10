FactoryBot.define do
  factory :sport_template do
    district
    name            { Faker::Sport.sport }
    athletic_season { :fall }
    gender_config   { :separate }
    active          { true }

    trait :fall       do; athletic_season { :fall       }; end
    trait :winter     do; athletic_season { :winter     }; end
    trait :spring     do; athletic_season { :spring     }; end
    trait :year_round do; athletic_season { :year_round }; end

    trait :combined do; gender_config { :combined }; end
    trait :separate do; gender_config { :separate }; end
  end
end
