FactoryBot.define do
  factory :access_log do
    accessor      { association :user }
    accessed_user { association :user }
    accessor_role { "head_coach" }
    reason        { :conduct_concern }
    sport         { nil }

    trait :anomaly_flagged do
      anomaly_flagged { true }
      anomaly_score   { 0.85 }
      anomaly_reason  { "Repeated access to same student in short window" }
    end
  end
end
