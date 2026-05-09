FactoryBot.define do
  factory :school do
    district
    sequence(:name) { |n| "#{Faker::Address.city} High School #{n}" }
    city   { Faker::Address.city }
    state  { Faker::Address.state_abbr }
    active { true }
  end
end
