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
    def self.thresholds
      Rails.application.config.gemma.dig(:moderation, :thresholds)
    end

    def self.questionable_threshold = thresholds[:questionable].to_f
    def self.severe_threshold       = thresholds[:severe].to_f

    Result = Data.define(:tier, :flagged, :blocked, :score, :reason, :category)

    # Used by the private/production path where mobile sends an explicit flagged signal.
    def self.apply(message:, score:, flagged:, reason: nil, category: nil)
      new.call(message, score: score, flagged: flagged, reason: reason, category: category)
    end

    # Used by the demo path and the private-repo mutations where flagged is derived from score.
    def self.call(message, score:, reason: nil, category: nil, flagged: nil)
      new.call(message, score: score, reason: reason, category: category, flagged: flagged)
    end

    def call(message, score:, reason: nil, category: nil, flagged: nil)
      score = score.to_f
      tier  = classify(score, flagged)

      message.assign_attributes(
        moderation_score: score,
        flagged:          tier != "clear",
        flag_reason:      reason,
        flag_category:    category,
        flag_action:      flag_action_for(tier)
      )

      Result.new(tier: tier, flagged: tier != "clear", blocked: tier == "severe", score: score, reason: reason, category: category)
    end

    private

    def classify(score, flagged_override)
      q = self.class.questionable_threshold
      s = self.class.severe_threshold

      return "clear" unless flagged_override || score >= q

      score >= s ? "severe" : "questionable"
    end

    def flag_action_for(tier)
      case tier
      when "severe"       then "blocked"
      when "questionable" then "held"
      end
    end
  end
end
