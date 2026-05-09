module Gemma
  # Applies a pre-computed on-device moderation result to a message or direct message.
  #
  # COPPA/FERPA: Student message content is analyzed entirely on-device by Gemma 4 E4B
  # in the mobile app. This service receives the result payload from the mobile client
  # and applies tier logic — it does NOT send content to the FastAPI.
  #
  # Tiers (thresholds configured in config/gemma.yml):
  #   clear        (score < 0.40) — message delivers normally
  #   questionable (0.40–0.74)   — message delivers flagged; head coach notified for review
  #   severe       (score >= 0.75) — message blocked; head coach + AD notified immediately
  class ContentModerator
    THRESHOLDS = Rails.application.config.gemma.dig("moderation", "thresholds")
    QUESTIONABLE_THRESHOLD = THRESHOLDS["questionable"].to_f
    SEVERE_THRESHOLD = THRESHOLDS["severe"].to_f

    Result = Data.define(:tier, :flagged, :blocked, :score, :reason)

    # Parses a moderation payload from the mobile client and applies it to the record.
    # Returns a Result. Does not save — caller must persist via apply_moderation_result!
    def self.apply(message:, score:, flagged:, reason: nil)
      new.apply(message: message, score: score, flagged: flagged, reason: reason)
    end

    def apply(message:, score:, flagged:, reason: nil)
      score = score.to_f
      tier = classify(score, flagged)
      blocked = tier == "severe"

      message.assign_attributes(
        moderation_score: score,
        flagged: tier != "clear",
        flag_reason: reason,
        flag_action: flag_action_for(tier)
      )

      Result.new(tier: tier, flagged: tier != "clear", blocked: blocked, score: score, reason: reason)
    end

    private

    def classify(score, flagged)
      return "clear" unless flagged || score >= QUESTIONABLE_THRESHOLD

      if score >= SEVERE_THRESHOLD
        "severe"
      elsif score >= QUESTIONABLE_THRESHOLD || flagged
        "questionable"
      else
        "clear"
      end
    end

    def flag_action_for(tier)
      case tier
      when "severe"       then "blocked"
      when "questionable" then "held"
      end
    end
  end
end
