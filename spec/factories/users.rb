FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    email      { Faker::Internet.unique.email }
    password   { "password123" }
    active     { true }

    trait :inactive do
      active    { false }
      deleted_at { Time.current }
    end
  end
end
