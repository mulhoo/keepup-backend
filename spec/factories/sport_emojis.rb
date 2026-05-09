FactoryBot.define do
  factory :sport_emoji do
    sport
    requested_by { association :user }
    name         { ":#{Faker::Lorem.unique.word.downcase}:" }
    image_url    { Faker::Internet.url(host: "example.com", path: "/emoji/#{SecureRandom.hex(4)}.png") }
    status       { :pending }

    trait :approved do
      status      { :approved }
      reviewed_by { association :user }
      reviewed_at { Time.current }
    end

    trait :rejected do
      status      { :rejected }
      reviewed_by { association :user }
      reviewed_at { Time.current }
    end

    trait :auto_rejected do
      status          { :auto_rejected }
      gemma_overridden { false }
    end

    trait :appealed do
      status      { :appealed }
      appealed_at { Time.current }
      appeal_reason { "This is a team-appropriate emoji" }
    end

    trait :overridden do
      status           { :approved }
      gemma_overridden { true }
      reviewed_by      { association :user }
      reviewed_at      { Time.current }
    end
  end
end
