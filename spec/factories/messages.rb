FactoryBot.define do
  factory :message do
    channel
    sender  { association :user }
    content { Faker::Lorem.sentence }

    trait :flagged do
      flagged          { true }
      moderation_score { 0.55 }
      flag_reason      { "potentially harmful content" }
      flag_action      { "held" }
    end

    trait :blocked do
      flagged          { true }
      moderation_score { 0.90 }
      flag_reason      { "explicit threat of violence" }
      flag_action      { "blocked" }
    end

    trait :deleted do
      deleted_at { Time.current }
      deleted_by { association :user }
    end

    trait :pinned do
      pinned_at  { Time.current }
      pinned_by  { association :user }
    end
  end
end
