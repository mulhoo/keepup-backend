FactoryBot.define do
  factory :direct_message do
    dm_conversation
    sender  { dm_conversation.participant_a }
    content { Faker::Lorem.sentence }

    trait :flagged do
      flagged          { true }
      moderation_score { 0.92 }
      flag_reason      { "inappropriate content" }
    end

    trait :read do
      read_at { Time.current }
    end
  end
end
