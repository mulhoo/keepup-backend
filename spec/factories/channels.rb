FactoryBot.define do
  factory :channel do
    sport
    created_by      { association :user }
    name            { Faker::Lorem.unique.word.capitalize }
    channel_type    { :conversation }
    private         { false }
    student_created { false }
    system_generated { false }
    active          { true }

    trait :broadcast do
      channel_type { :broadcast }
    end

    trait :athletes_only do
      channel_type { :athletes_only }
    end

    trait :coaches_only do
      channel_type { :coaches_only }
    end

    trait :system_generated do
      system_generated { true }
    end
  end
end
