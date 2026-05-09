FactoryBot.define do
  factory :dm_conversation do
    sport
    # participant_a must have the lower ID — use DmConversation.between in specs
    # when you need the ordering enforced automatically.
    participant_a { association :user }
    participant_b { association :user }

    after(:build) do |conv|
      if conv.participant_a_id && conv.participant_b_id &&
         conv.participant_a_id > conv.participant_b_id
        conv.participant_a, conv.participant_b =
          conv.participant_b, conv.participant_a
      end
    end
  end
end
