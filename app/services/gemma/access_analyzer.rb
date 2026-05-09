module Gemma
  # Calls the FastAPI /analyze_access endpoint with the current access log
  # and recent history for the same accessor.
  # Returns an AnalysisResult and persists anomaly fields on the access log.
  # Called asynchronously via GemmaAccessAnalysisJob — never blocks the request path.
  class AccessAnalyzer
    RECENT_LOG_WINDOW = 50

    AnalysisResult = Data.define(:anomaly_flagged, :anomaly_score, :anomaly_reason, :patterns_detected)

    def self.analyze(access_log)
      new.analyze(access_log)
    end

    def analyze(access_log)
      recent = recent_logs_for(access_log)
      response = GemmaClient.post("/analyze_access", build_payload(access_log, recent))
      result = parse_response(response)
      persist_result(access_log, result)
      result
    rescue GemmaClient::ServiceUnavailable => e
      Rails.logger.warn("[Gemma::AccessAnalyzer] Service unavailable: #{e.message}")
      nil
    end

    private

    def recent_logs_for(access_log)
      AccessLog
        .where(accessor_id: access_log.accessor_id)
        .where.not(id: access_log.id)
        .order(created_at: :desc)
        .limit(RECENT_LOG_WINDOW)
    end

    def build_payload(current, recent)
      {
        current_log: serialize_log(current),
        recent_logs: recent.map { |l| serialize_log(l) }
      }
    end

    def serialize_log(log)
      {
        accessor_id: log.accessor_id,
        accessor_role: log.accessor_role,
        accessed_user_id: log.accessed_user_id,
        resource_type: log.resource_type,
        resource_id: log.resource_id,
        sport_id: log.sport_id,
        accessed_at: log.created_at.iso8601
      }
    end

    def parse_response(response)
      AnalysisResult.new(
        anomaly_flagged: response[:anomaly_flagged],
        anomaly_score: response[:anomaly_score].to_f,
        anomaly_reason: response[:anomaly_reason],
        patterns_detected: Array(response[:patterns_detected])
      )
    end

    def persist_result(access_log, result)
      access_log.update_columns(
        anomaly_flagged: result.anomaly_flagged,
        anomaly_score: result.anomaly_score,
        anomaly_reason: result.anomaly_reason
      )
    end
  end
end
