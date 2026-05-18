class DeeplTranslator
  API_URL = "https://api.anthropic.com/v1/messages".freeze
  MODEL   = "claude-haiku-4-5-20251001".freeze

  TranslationResult = Data.define(:translated_text, :language_name)

  def self.available?
    ENV["ANTHROPIC_API_KEY"].present?
  end

  def self.translate(text:, target_language:)
    new.translate(text:, target_language:)
  end

  def translate(text:, target_language:)
    uri  = URI(API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path)
    request["x-api-key"]         = ENV["ANTHROPIC_API_KEY"]
    request["anthropic-version"]  = "2023-06-01"
    request["content-type"]       = "application/json"
    request.body = {
      model:      MODEL,
      max_tokens: 1024,
      messages:   [ {
        role:    "user",
        content: "Translate the following text to #{target_language}. Return only the translated text with no explanation or commentary.\n\n#{text}"
      } ]
    }.to_json

    response = http.request(request)
    raise "Anthropic error #{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

    body       = JSON.parse(response.body)
    translated = body.dig("content", 0, "text").to_s.strip
    raise "Empty translation response" if translated.blank?

    TranslationResult.new(translated_text: translated, language_name: target_language.titleize)
  end
end
