require 'rails_helper'

RSpec.describe DmConversation, type: :model do
  describe "participant ordering" do
    it "is invalid when participant_a has a higher ID than participant_b" do
      users = create_list(:user, 2).sort_by(&:id)
      # Build directly to bypass the factory's auto-swap after(:build) hook
      conv = DmConversation.new(participant_a: users[1], participant_b: users[0], sport: create(:sport))
      expect(conv).not_to be_valid
      expect(conv.errors[:base]).to include("participant_a must have the lower ID")
    end

    it "is valid when participant_a has the lower ID" do
      users = create_list(:user, 2).sort_by(&:id)
      sport = create(:sport)
      create(:sport_membership, :student, user: users[0], sport: sport)
      create(:sport_membership, :student, user: users[1], sport: sport)
      conv = build(:dm_conversation, participant_a: users[0], participant_b: users[1], sport: sport)
      expect(conv).to be_valid
    end
  end

  describe ".between" do
    it "always assigns the lower ID user as participant_a" do
      sport  = create(:sport, :active)
      users  = create_list(:user, 2).sort_by(&:id)
      users.each { |u| create(:sport_membership, :student, user: u, sport: sport) }

      conv = DmConversation.between(users[1], users[0], sport)
      expect(conv.participant_a_id).to eq(users[0].id)
      expect(conv.participant_b_id).to eq(users[1].id)
    end

    it "returns the existing conversation on a second call" do
      sport = create(:sport, :active)
      users = create_list(:user, 2).sort_by(&:id)
      users.each { |u| create(:sport_membership, :student, user: u, sport: sport) }

      first  = DmConversation.between(users[0], users[1], sport)
      second = DmConversation.between(users[1], users[0], sport)
      expect(first.id).to eq(second.id)
    end
  end

  describe "blocked interaction rules" do
    let(:sport)   { create(:sport, :active) }
    let(:parent)  { create(:user) }
    let(:student) { create(:user) }

    before do
      create(:sport_membership, :parent,  user: parent,  sport: sport)
      create(:sport_membership, :student, user: student, sport: sport)
    end

    it "blocks a parent from DMing another student (not their child)" do
      users = [parent, student].sort_by(&:id)
      conv  = build(:dm_conversation, participant_a: users[0], participant_b: users[1], sport: sport)
      expect(conv).not_to be_valid
      expect(conv.errors[:base]).to include("this combination of roles cannot exchange direct messages")
    end

    it "allows a coach to DM a student" do
      coach = create(:user)
      create(:sport_membership, :head_coach, user: coach, sport: sport)
      users = [coach, student].sort_by(&:id)
      conv  = build(:dm_conversation, participant_a: users[0], participant_b: users[1], sport: sport)
      expect(conv).to be_valid
    end
  end
end
