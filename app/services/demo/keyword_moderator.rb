module Demo
  class KeywordModerator
    SEVERE = [
      /kill/i, /murder/i, /shoot/i, /stab/i, /bomb/i, /weapon/i,
      /threat(en)?/i, /rape/i, /suicide/i, /hurt (you|them|him|her)/i,
      /i('m| am) going to (kill|hurt|attack)/i
    ].freeze

    QUESTIONABLE = [
      /hate (you|him|her|them)/i, /\bidiots?\b/i, /\bstupid\b/i,
      /\bugly\b/i, /\bloser\b/i, /shut up/i, /\bdumb\b/i, /\bfat\b/i,
      /you suck/i, /go to hell/i
    ].freeze

    def self.score(content)
      text = content.to_s

      if SEVERE.any? { |pattern| text.match?(pattern) }
        { score: rand(0.80..0.96).round(2), reason: "Detected language consistent with threats or serious harm." }
      elsif QUESTIONABLE.any? { |pattern| text.match?(pattern) }
        { score: rand(0.42..0.68).round(2), reason: "Detected potentially hostile or demeaning language." }
      else
        { score: rand(0.02..0.18).round(2), reason: nil }
      end
    end
  end
end
