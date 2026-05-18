module Demo
  class ModerateController < Demo::ApplicationController
    include DemoGuard
    before_action :require_demo_mode

    def create
      content = params[:content].to_s.strip
      return render json: { error: "Content can't be blank" }, status: :unprocessable_entity if content.blank?

      result = call_gemma(content)
      render json: result
    end

    private

    def call_gemma(content)
      response = GemmaClient.post("/moderate", { content:, sender_role: "student" })
      score    = response[:score].to_f.clamp(0.0, 1.0)
      { score:, tier: tier_from(score), flagged: score >= 0.40, source: "gemma4" }
    rescue GemmaClient::ServiceUnavailable
      kw = Demo::KeywordModerator.score(content)
      score = kw[:score].to_f
      { score:, tier: tier_from(score), flagged: score >= 0.40, source: "keyword_fallback" }
    end

    def tier_from(score)
      return "severe"       if score >= 0.75
      return "questionable" if score >= 0.40
      "clear"
    end
  end
end
