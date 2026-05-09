require "rails_helper"

RSpec.describe Gemma::AccessAnalyzer do
  let(:accessor)      { create(:user) }
  let(:accessed_user) { create(:user) }
  let(:access_log) do
    create(:access_log,
      accessor: accessor,
      accessed_user: accessed_user,
      accessor_role: "head_coach",
      reason: :conduct_concern
    )
  end

  describe ".analyze" do
    context "when the Gemma service returns an anomaly" do
      before do
        allow(GemmaClient).to receive(:post).with("/analyze_access", anything).and_return(
          anomaly_flagged: true,
          anomaly_score: 0.82,
          anomaly_reason: "Repeated access to same student DMs within 10 minutes",
          patterns_detected: [ "repeated_access", "short_window" ]
        )
      end

      it "persists the anomaly result on the access log" do
        described_class.analyze(access_log)
        access_log.reload

        expect(access_log.anomaly_flagged).to be true
        expect(access_log.anomaly_score).to be_within(0.001).of(0.82)
        expect(access_log.anomaly_reason).to eq("Repeated access to same student DMs within 10 minutes")
      end

      it "returns an AnalysisResult with patterns" do
        result = described_class.analyze(access_log)

        expect(result.anomaly_flagged).to be true
        expect(result.patterns_detected).to include("repeated_access")
      end
    end

    context "when the Gemma service returns no anomaly" do
      before do
        allow(GemmaClient).to receive(:post).with("/analyze_access", anything).and_return(
          anomaly_flagged: false,
          anomaly_score: 0.1,
          anomaly_reason: nil,
          patterns_detected: []
        )
      end

      it "marks the log as clean" do
        described_class.analyze(access_log)
        access_log.reload

        expect(access_log.anomaly_flagged).to be false
        expect(access_log.anomaly_score).to be_within(0.001).of(0.1)
      end
    end

    context "when the Gemma service is unavailable" do
      before do
        allow(GemmaClient).to receive(:post).and_raise(GemmaClient::ServiceUnavailable, "timeout")
      end

      it "returns nil and does not raise" do
        expect { described_class.analyze(access_log) }.not_to raise_error
        expect(described_class.analyze(access_log)).to be_nil
      end

      it "does not modify the access log" do
        described_class.analyze(access_log)
        expect(access_log.reload.anomaly_flagged).to be false
      end
    end

    it "includes the last 50 access logs for the same accessor in the payload" do
      create_list(:access_log, 3, accessor: accessor, accessed_user: accessed_user,
                  accessor_role: "head_coach", reason: :conduct_concern)

      allow(GemmaClient).to receive(:post).with("/analyze_access", hash_including(
        recent_logs: an_instance_of(Array)
      )).and_return(anomaly_flagged: false, anomaly_score: 0.0, anomaly_reason: nil, patterns_detected: [])

      described_class.analyze(access_log)
      expect(GemmaClient).to have_received(:post)
    end
  end
end
