FactoryBot.define do
  factory :team_level do
    sport
    name          { "Varsity" }
    display_order { 0 }
    active        { true }

    trait :jv       do; name { "JV" };       display_order { 1 }; end
    trait :c_team   do; name { "C Team" };   display_order { 2 }; end
    trait :freshman do; name { "Freshman" }; display_order { 3 }; end
  end
end
