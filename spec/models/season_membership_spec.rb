require 'rails_helper'

RSpec.describe SeasonMembership, type: :model do
  describe "validations" do
    subject { build(:season_membership) }

    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:season) }

    it "enforces one membership per user per season" do
      existing  = create(:season_membership)
      duplicate = build(:season_membership, user: existing.user, season: existing.season)
      expect(duplicate).not_to be_valid
    end
  end

  describe "is_captain" do
    it "can be set on a student" do
      membership = build(:season_membership, :captain)
      expect(membership).to be_valid
    end

    it "cannot be set on a head coach" do
      membership = build(:season_membership, :head_coach, is_captain: true)
      expect(membership).not_to be_valid
      expect(membership.errors[:is_captain]).to include("can only be set for students")
    end

    it "cannot be set on an assistant coach" do
      membership = build(:season_membership, :assistant_coach, is_captain: true)
      expect(membership).not_to be_valid
    end

    it "cannot be set on a parent" do
      membership = build(:season_membership, :parent, is_captain: true)
      expect(membership).not_to be_valid
    end
  end

  describe ".captains scope" do
    it "returns only active student captains" do
      captain     = create(:season_membership, :captain)
      non_captain = create(:season_membership, :student)
      coach       = create(:season_membership, :head_coach)

      expect(SeasonMembership.captains).to include(captain)
      expect(SeasonMembership.captains).not_to include(non_captain, coach)
    end
  end

  describe "#remove!" do
    it "sets status to removed and records removed_at" do
      membership = create(:season_membership)
      membership.remove!
      expect(membership.reload.status).to eq("removed")
      expect(membership.removed_at).to be_present
    end
  end
end
