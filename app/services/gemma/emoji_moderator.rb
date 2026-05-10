module Gemma
  # Calls the FastAPI /moderate_emoji endpoint with the submitted sport emoji image.
  # Gemma acts as a pre-filter only — a human always makes the final approval decision.
  #
  # Outcomes:
  #   approved_for_queue: true  → status stays :pending, enters captain/coach approval queue
  #   approved_for_queue: false → status set to :auto_rejected, student notified
  class EmojiModerator
    ModerationResult = Data.define(:approved_for_queue, :score, :reason, :categories)

    def self.moderate(sport_emoji)
      new.moderate(sport_emoji)
    end

    def moderate(sport_emoji)
      response = GemmaClient.post("/moderate_emoji", build_payload(sport_emoji))
      result = parse_response(response)
      apply_result(sport_emoji, result)
      result
    rescue GemmaClient::ServiceUnavailable => e
      Rails.logger.warn("[Gemma::EmojiModerator] Service unavailable: #{e.message}")
      # Fail open — let it enter the human queue rather than silently block the student
      sport_emoji.pending!
      nil
    end

    private

    def build_payload(sport_emoji)
      current_season = sport_emoji.sport.current_season
      {
        image_url: sport_emoji.image_url,
        emoji_name: sport_emoji.name,
        sport_id: sport_emoji.sport_id,
        requested_by_role: current_season && sport_emoji.requested_by&.season_role(current_season)
      }
    end

    def parse_response(response)
      ModerationResult.new(
        approved_for_queue: response[:approved_for_queue],
        score: response[:score].to_f,
        reason: response[:reason],
        categories: Array(response[:categories])
      )
    end

    def apply_result(sport_emoji, result)
      if result.approved_for_queue
        sport_emoji.pending!
      else
        sport_emoji.auto_rejected!
      end
    end
  end
end
