require "rails_helper"

RSpec.describe Gemma::EmojiModerator do
  let(:sport_emoji) { create(:sport_emoji) }

  describe ".moderate" do
    context "when Gemma approves the image" do
      before do
        allow(GemmaClient).to receive(:post).with("/moderate_emoji", anything).and_return(
          approved_for_queue: true,
          score: 0.05,
          reason: nil,
          categories: [ "none" ]
        )
      end

      it "sets the emoji status to pending" do
        described_class.moderate(sport_emoji)
        expect(sport_emoji.reload.status).to eq("pending")
      end

      it "returns a ModerationResult with approved_for_queue true" do
        result = described_class.moderate(sport_emoji)
        expect(result.approved_for_queue).to be true
      end
    end

    context "when Gemma rejects the image" do
      before do
        allow(GemmaClient).to receive(:post).with("/moderate_emoji", anything).and_return(
          approved_for_queue: false,
          score: 0.91,
          reason: "Image contains explicit content",
          categories: [ "nudity" ]
        )
      end

      it "sets the emoji status to auto_rejected" do
        described_class.moderate(sport_emoji)
        expect(sport_emoji.reload.status).to eq("auto_rejected")
      end

      it "returns a ModerationResult with the rejection reason" do
        result = described_class.moderate(sport_emoji)
        expect(result.reason).to eq("Image contains explicit content")
        expect(result.categories).to include("nudity")
      end
    end

    context "when the Gemma service is unavailable" do
      before do
        allow(GemmaClient).to receive(:post).and_raise(GemmaClient::ServiceUnavailable, "timeout")
      end

      it "fails open — sets status to pending so a human reviews it" do
        described_class.moderate(sport_emoji)
        expect(sport_emoji.reload.status).to eq("pending")
      end

      it "returns nil without raising" do
        expect { described_class.moderate(sport_emoji) }.not_to raise_error
        expect(described_class.moderate(sport_emoji)).to be_nil
      end
    end
  end
end
