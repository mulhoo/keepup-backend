require 'rails_helper'

RSpec.describe SportEmoji, type: :model do
  describe "validations" do
    subject { build(:sport_emoji) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:image_url) }
    it { is_expected.to belong_to(:sport) }
    it { is_expected.to belong_to(:requested_by) }

    it "requires name to be in :name: format" do
      emoji = build(:sport_emoji, name: "swimmer")
      expect(emoji).not_to be_valid
      expect(emoji.errors[:name]).to include("must be in :name: format")
    end

    it "accepts valid :name: format" do
      emoji = build(:sport_emoji, name: ":swimmer:")
      expect(emoji).to be_valid
    end

    it "enforces uniqueness of name per sport" do
      existing = create(:sport_emoji, name: ":wave:")
      duplicate = build(:sport_emoji, sport: existing.sport, name: ":wave:")
      expect(duplicate).not_to be_valid
    end

    it "allows the same name across different sports" do
      create(:sport_emoji, name: ":wave:")
      other = build(:sport_emoji, name: ":wave:")
      expect(other).to be_valid
    end
  end

  describe "status flow" do
    it "starts as pending" do
      expect(build(:sport_emoji).status).to eq("pending")
    end

    it "identifies approvable appeal states" do
      expect(build(:sport_emoji, :auto_rejected).approvable_by_appeal?).to be true
      expect(build(:sport_emoji, :appealed).approvable_by_appeal?).to be true
      expect(build(:sport_emoji, :approved).approvable_by_appeal?).to be false
    end
  end

  describe "gemma feedback" do
    it "marks gemma_overridden when a coach approves an auto-rejected emoji" do
      emoji = create(:sport_emoji, :overridden)
      expect(emoji.gemma_overridden).to be true
      expect(emoji.status).to eq("approved")
    end
  end
end
