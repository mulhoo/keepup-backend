FactoryBot.define do
  factory :message_flag do
    message
    flagged_by { association :user }
    reason     { Faker::Lorem.sentence }
    status     { :pending }

    trait :reviewed do
      status      { :reviewed }
      reviewed_by { association :user }
      reviewed_at { Time.current }
    end

    trait :escalated do
      status        { :escalated }
      reviewed_by   { association :user }
      reviewed_at   { 1.hour.ago }
      escalated_to  { association :user }
      escalated_at  { Time.current }
    end

    trait :resolved do
      status       { :resolved }
      reviewed_by  { association :user }
      reviewed_at  { 2.hours.ago }
      resolved_by  { association :user }
      resolved_at  { Time.current }
    end
  end
end
