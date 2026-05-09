FactoryBot.define do
  factory :moderation_notification do
    recipient         { association :user }
    message           { association :message }
    notification_type { :questionable_review }
    recipient_role    { :head_coach }

    trait :severe do
      notification_type { :severe_alert }
    end

    trait :for_ad do
      recipient_role { :athletic_director }
    end

    trait :read do
      read_at { Time.current }
    end

    trait :for_dm do
      message        { nil }
      direct_message { association :direct_message }
    end
  end
end
