require "rails_helper"

RSpec.describe GemmaAccessAnalysisJob do
  let(:access_log) { create(:access_log) }

  describe "#perform" do
    it "calls Gemma::AccessAnalyzer with the access log" do
      allow(Gemma::AccessAnalyzer).to receive(:analyze)
      described_class.new.perform(access_log.id)
      expect(Gemma::AccessAnalyzer).to have_received(:analyze).with(access_log)
    end

    it "does nothing when the access log does not exist" do
      allow(Gemma::AccessAnalyzer).to receive(:analyze)
      described_class.new.perform(0)
      expect(Gemma::AccessAnalyzer).not_to have_received(:analyze)
    end
  end
end
