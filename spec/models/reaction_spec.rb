require 'rails_helper'

RSpec.describe Reaction, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:emoji) }
    it { is_expected.to belong_to(:user) }

    it "is valid with a message" do
      reaction = build(:reaction, message: create(:message))
      expect(reaction).to be_valid
    end

    it "is valid on a direct message" do
      dm       = create(:direct_message)
      reaction = build(:reaction, message: nil, direct_message: dm)
      expect(reaction).to be_valid
    end

    it "is invalid with both message and direct_message set" do
      dm       = create(:direct_message)
      msg      = create(:message)
      reaction = build(:reaction, message: msg, direct_message: dm)
      expect(reaction).not_to be_valid
      expect(reaction.errors[:base]).to include("must belong to exactly one of message or direct_message")
    end

    it "is invalid with neither message nor direct_message" do
      reaction = build(:reaction, message: nil, direct_message: nil)
      expect(reaction).not_to be_valid
    end

    it "prevents duplicate emoji reactions from the same user on the same message" do
      existing = create(:reaction, emoji: "👍")
      duplicate = build(:reaction, user: existing.user, message: existing.message, emoji: "👍")
      expect(duplicate).not_to be_valid
    end

    it "allows the same user to react with a different emoji" do
      existing = create(:reaction, emoji: "👍")
      other    = build(:reaction, user: existing.user, message: existing.message, emoji: "❤️")
      expect(other).to be_valid
    end
  end
end
