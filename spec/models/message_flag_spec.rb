require 'rails_helper'

RSpec.describe MessageFlag, type: :model do
  describe "validations" do
    subject { build(:message_flag) }

    it { is_expected.to validate_presence_of(:message) }
    it { is_expected.to validate_presence_of(:flagged_by) }
    it { is_expected.to belong_to(:message) }
    it { is_expected.to belong_to(:flagged_by) }

    it "prevents a user from flagging the same message twice" do
      existing = create(:message_flag)
      duplicate = build(:message_flag, message: existing.message, flagged_by: existing.flagged_by)
      expect(duplicate).not_to be_valid
    end

    it "allows different users to flag the same message" do
      existing = create(:message_flag)
      other    = build(:message_flag, message: existing.message, flagged_by: create(:user))
      expect(other).to be_valid
    end
  end

  describe "#escalate!" do
    it "sets status to escalated and records the AD and timestamp" do
      flag = create(:message_flag, :reviewed)
      ad   = create(:user)
      flag.escalate!(ad)

      expect(flag.reload.status).to eq("escalated")
      expect(flag.escalated_to).to eq(ad)
      expect(flag.escalated_at).to be_present
    end
  end

  describe "#resolve!" do
    it "sets status to resolved and records resolver and timestamp" do
      flag     = create(:message_flag, :escalated)
      resolver = create(:user)
      flag.resolve!(resolver)

      expect(flag.reload.status).to eq("resolved")
      expect(flag.resolved_by).to eq(resolver)
      expect(flag.resolved_at).to be_present
    end
  end
end
