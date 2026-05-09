FactoryBot.define do
  factory :district do
    name    { Faker::Address.unique.city + " School District" }
    city    { Faker::Address.city }
    state   { Faker::Address.state_abbr }
    country { "US" }
    active  { true }
  end
end
