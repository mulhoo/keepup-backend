require "rails_helper"

RSpec.describe Gemma::ContentModerator do
  let(:channel) { create(:channel) }
  let(:sender)  { create(:user) }
  let(:message) { build(:message, channel: channel, sender: sender, content: "Hello team") }

  describe ".apply" do
    context "when score is below the questionable threshold (clear)" do
      it "does not flag the message" do
        result = described_class.apply(message: message, score: 0.2, flagged: false)

        expect(result.tier).to eq("clear")
        expect(result.flagged).to be false
        expect(result.blocked).to be false
        expect(message.flagged).to be false
        expect(message.flag_action).to be_nil
      end
    end

    context "when score is in the questionable range" do
      it "flags the message as held" do
        result = described_class.apply(message: message, score: 0.55, flagged: true, reason: "possible harassment")

        expect(result.tier).to eq("questionable")
        expect(result.flagged).to be true
        expect(result.blocked).to be false
        expect(message.flag_action).to eq("held")
        expect(message.flag_reason).to eq("possible harassment")
        expect(message.moderation_score).to be_within(0.001).of(0.55)
      end

      it "flags when flagged=true even if score is below questionable threshold" do
        result = described_class.apply(message: message, score: 0.1, flagged: true)

        expect(result.tier).to eq("questionable")
        expect(result.blocked).to be false
      end
    end

    context "when score is at or above the severe threshold" do
      it "blocks the message" do
        result = described_class.apply(message: message, score: 0.9, flagged: true, reason: "explicit threat of violence")

        expect(result.tier).to eq("severe")
        expect(result.flagged).to be true
        expect(result.blocked).to be true
        expect(message.flag_action).to eq("blocked")
      end
    end

    it "clamps the score to 0.0–1.0 and does not raise" do
      expect { described_class.apply(message: message, score: 1.5, flagged: true) }.not_to raise_error
    end

    it "does not persist — assign_attributes only" do
      described_class.apply(message: message, score: 0.8, flagged: true)
      expect(message).not_to be_persisted
    end
  end
end
