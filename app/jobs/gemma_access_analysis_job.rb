class GemmaAccessAnalysisJob < ApplicationJob
  queue_as :default

  # Analyzes a single access log for behavioral anomalies via Gemma 4.
  # Runs asynchronously — never blocks the request path.
  def perform(access_log_id)
    access_log = AccessLog.find_by(id: access_log_id)
    return unless access_log

    Gemma::AccessAnalyzer.analyze(access_log)
  end
end
