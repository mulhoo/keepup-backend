FactoryBot.define do
  factory :reaction do
    user
    message
    emoji { [ "👍", "❤️", "😂", "🔥", "👏" ].sample }
    direct_message { nil }
    sport_emoji    { nil }

    trait :on_direct_message do
      message        { nil }
      direct_message { association :direct_message }
    end

    trait :custom_emoji do
      sport_emoji { association :sport_emoji, :approved }
      emoji       { sport_emoji.name }
    end
  end
end
