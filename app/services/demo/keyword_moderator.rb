module Demo
  # Fallback content scorer used when the Gemma 4 FastAPI is unavailable.
  # Also used as the primary scorer in the demo environment.
  #
  # Scoring is sport-aware: if coaches at a school have repeatedly approved messages
  # in a given category for a given sport, scores for that category are reduced so
  # Gemma stops flagging them. This is the on-rails side of the learning loop —
  # the mobile Gemma model does the same via the synced safety_review_signals table.
  #
  # Thresholds (from config/gemma.yml): questionable ≥0.40, severe ≥0.75.
  # Learning only adjusts scores within the questionable tier — severe content
  # is never softened by coach approvals.
  #
  # Severity policy:
  #   Severe  — explicit threats toward a person, slurs, self-harm language,
  #              weapons references, off-platform solicitation by adults.
  #   Questionable — competitive trash talk, generic hostility, hyperbole.
  #   Normal athlete expressions ("lose it", "go crazy", "I'll destroy them") are
  #   expected to score below the questionable threshold and flow through.
  class KeywordModerator
    RULES = [
      # Direct personal threat: "I'm going to kill/hurt/attack Coach"
      # Negative lookahead prevents catching sports idioms ("kill it at the meet",
      # "kill this race", "hurt the other team").
      { pattern: /i('m| am) going to (kill|hurt|attack|stab|shoot) (?!it\b|this\b|the (?:game|meet|race|match|relay|practice|comp(?:etition)?))/i,
        category: "explicit_threat", base_score: 0.92, learnable: false },

      # Weapons
      { pattern: /\b(stab|bomb|weapon|gun|knife)\b/i,
        category: "explicit_threat", base_score: 0.88, learnable: false },

      # Sexual violence
      { pattern: /\b(rape|molest)\b/i,
        category: "explicit_threat", base_score: 0.95, learnable: false },

      # Self-harm
      { pattern: /\b(suicide|kill myself|end my life|want to die)\b/i,
        category: "self_harm", base_score: 0.90, learnable: false },

      # Slurs — racial, ethnic, homophobic, gender
      { pattern: /\b(nigga|nigger|faggot|spic|chink|kike|dyke|tranny|retard)\b/i,
        category: "slur", base_score: 0.95, learnable: false },

      # Off-platform solicitation — flagged because coaches/admins can be predators.
      # "Let's talk at practice" / "see you at school" are NOT in this pattern.
      # Only triggers on explicit off-app invitations or sharing personal contact info.
      { pattern: /\b(my (?:personal |cell )?(?:number|phone) is|text me at|call me at|add me on (?:snap(?:chat)?|insta(?:gram)?|tiktok|discord)|dm me (?:on|there)|off (?:the |this )?app|not on (?:the |this )?app|take this (?:off|offline)|move this off|outside (?:the )?app)\b/i,
        category: "off_platform_contact", base_score: 0.82, learnable: false },

      { pattern: /\b(kill|murder|destroy|annihilate|demolish|obliterate|massacre)\b/i,
        category: "competitive_aggression", base_score: 0.55, learnable: true },
      { pattern: /\b(drown|bury|crush|smash|wreck|torch|smoke)\b/i,
        category: "competitive_aggression", base_score: 0.48, learnable: true },
      { pattern: /\b(dominate|own|slaughter|wipe (?:them|you) out)\b/i,
        category: "competitive_aggression", base_score: 0.46, learnable: true },
      { pattern: /hate (you|him|her|them)\b/i,
        category: "general_hostility", base_score: 0.60, learnable: true },
      { pattern: /\b(idiot|stupid|loser|ugly|dumb|fat|moron|pathetic)\b/i,
        category: "general_hostility", base_score: 0.52, learnable: true },
      { pattern: /\b(shut up|you suck|go to hell|screw you)\b/i,
        category: "general_hostility", base_score: 0.50, learnable: true }
    ].freeze

    SIGNAL_MINIMUM = 3
    MAX_REDUCTION  = 0.40

    def self.score(content, sport_template_id: nil, school_id: nil)
      new(sport_template_id: sport_template_id, school_id: school_id).score(content)
    end

    def initialize(sport_template_id: nil, school_id: nil)
      @sport_template_id = sport_template_id
      @school_id         = school_id
    end

    def score(content)
      text = content.to_s
      rule = RULES.find { |r| text.match?(r[:pattern]) }
      return { score: rand(0.02..0.18).round(3), reason: nil, category: nil } unless rule

      adjusted = rule[:learnable] ? apply_learning(rule[:base_score], rule[:category]) : rule[:base_score]

      { score: adjusted.clamp(0.0, 1.0).round(3), reason: reason_for(rule[:category]), category: rule[:category] }
    end

    private

    def apply_learning(base_score, category)
      return base_score unless @school_id && @sport_template_id

      signals = SafetyReviewSignal
        .recent
        .where(school_id: @school_id, sport_template_id: @sport_template_id, category: category)

      count = signals.count
      return base_score if count < SIGNAL_MINIMUM

      approval_rate = signals.where(decision: :approved).count.to_f / count
      reduction     = [ (approval_rate - 0.50) * (MAX_REDUCTION / 0.50), 0.0 ].max.clamp(0.0, MAX_REDUCTION)
      base_score * (1.0 - reduction)
    end

    def reason_for(category)
      case category
      when "competitive_aggression"  then "Language common in competitive sports contexts — may be normal team talk."
      when "general_hostility"       then "Detected potentially hostile or demeaning language."
      when "explicit_threat"         then "Detected language consistent with a direct threat toward a person."
      when "self_harm"               then "Detected language that may indicate self-harm ideation."
      when "slur"                    then "Detected a slur or hate-based term."
      when "off_platform_contact"    then "Detected an invitation to communicate outside the platform. Flagged because this pattern can indicate inappropriate contact between adults and students."
      end
    end
  end
end
