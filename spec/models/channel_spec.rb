require 'rails_helper'

RSpec.describe Channel, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to belong_to(:season) }
    it { is_expected.to belong_to(:created_by) }
  end

  describe "channel_type enum" do
    it "supports all expected types" do
      expect(Channel.channel_types.keys).to match_array(%w[conversation broadcast athletes_only coaches_only])
    end
  end

  describe "system_generated" do
    it "is false by default" do
      expect(build(:channel).system_generated).to be false
    end

    it "can be marked as system generated" do
      channel = create(:channel, :system_generated)
      expect(channel.system_generated).to be true
    end
  end

  describe "#soft_delete!" do
    it "sets deleted_at and active to false" do
      channel = create(:channel)
      channel.soft_delete!(create(:user))
      expect(channel.reload.deleted_at).to be_present
      expect(channel.active).to be false
    end
  end
end
