require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_length_of(:password).is_at_least(8).allow_blank }
  end

  describe "associations" do
    it { is_expected.to have_many(:institution_roles).dependent(:destroy) }
    it { is_expected.to have_many(:sport_memberships).dependent(:destroy) }
    it { is_expected.to have_many(:channel_memberships).dependent(:destroy) }
    it { is_expected.to have_many(:reactions).dependent(:destroy) }
  end

  describe "#full_name" do
    it "returns first and last name" do
      user = build(:user, first_name: "Jane", last_name: "Doe")
      expect(user.full_name).to eq("Jane Doe")
    end
  end

  describe "#soft_delete!" do
    it "sets active to false and records deleted_at" do
      user = create(:user)
      user.soft_delete!
      expect(user.reload.active).to be false
      expect(user.deleted_at).to be_present
    end
  end

  describe "email normalization" do
    it "downcases and strips email before validation" do
      user = create(:user, email: "  TEST@EXAMPLE.COM  ")
      expect(user.email).to eq("test@example.com")
    end
  end

  describe "#coach_of?" do
    let(:sport) { create(:sport) }
    let(:user)  { create(:user) }

    it "returns true for head coaches" do
      create(:sport_membership, :head_coach, user: user, sport: sport)
      expect(user.coach_of?(sport)).to be true
    end

    it "returns true for assistant coaches" do
      create(:sport_membership, :assistant_coach, user: user, sport: sport)
      expect(user.coach_of?(sport)).to be true
    end

    it "returns false for students" do
      create(:sport_membership, :student, user: user, sport: sport)
      expect(user.coach_of?(sport)).to be false
    end
  end
end
