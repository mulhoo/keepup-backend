require 'rails_helper'

RSpec.describe SportMembership, type: :model do
  describe "validations" do
    subject { build(:sport_membership) }

    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:sport) }
    it { is_expected.to belong_to(:school) }

    it "enforces one membership per user per sport" do
      existing = create(:sport_membership)
      duplicate = build(:sport_membership, user: existing.user, sport: existing.sport)
      expect(duplicate).not_to be_valid
    end
  end

  describe "is_captain" do
    it "can be set on a student" do
      membership = build(:sport_membership, :captain)
      expect(membership).to be_valid
    end

    it "cannot be set on a head coach" do
      membership = build(:sport_membership, :head_coach, is_captain: true)
      expect(membership).not_to be_valid
      expect(membership.errors[:is_captain]).to include("can only be set for students")
    end

    it "cannot be set on an assistant coach" do
      membership = build(:sport_membership, :assistant_coach, is_captain: true)
      expect(membership).not_to be_valid
    end

    it "cannot be set on a parent" do
      membership = build(:sport_membership, :parent, is_captain: true)
      expect(membership).not_to be_valid
    end
  end

  describe ".captains scope" do
    it "returns only active student captains" do
      captain    = create(:sport_membership, :captain)
      non_captain = create(:sport_membership, :student)
      coach      = create(:sport_membership, :head_coach)

      expect(SportMembership.captains).to include(captain)
      expect(SportMembership.captains).not_to include(non_captain, coach)
    end
  end

  describe "#deactivate!" do
    it "sets active to false and records left_date" do
      membership = create(:sport_membership)
      membership.deactivate!
      expect(membership.reload.active).to be false
      expect(membership.left_date).to eq(Date.current)
    end
  end
end
