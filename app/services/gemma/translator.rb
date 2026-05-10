module Gemma
  # Translates coach/AD-authored text via the FastAPI /translate endpoint.
  #
  # COPPA boundary: only call this for content authored by coaches, ADs, and school admins.
  # Student message translation runs on-device in the mobile app — never through here.
  class Translator
    SUPPORTED_LANGUAGES = {
      "es"    => "Spanish",
      "zh-CN" => "Mandarin Chinese (Simplified)"
    }.freeze

    TranslationResult = Data.define(:translated_text, :source_language, :target_language, :language_name)

    def self.supported?(language_code)
      SUPPORTED_LANGUAGES.key?(language_code)
    end

    def self.translate(text:, target_language:, context: "message")
      new.translate(text:, target_language:, context:)
    end

    def translate(text:, target_language:, context: "message")
      unless SUPPORTED_LANGUAGES.key?(target_language)
        raise ArgumentError, "Unsupported language '#{target_language}'. Supported: #{SUPPORTED_LANGUAGES.keys.join(', ')}"
      end

      response = GemmaClient.post("/translate", {
        text:            text,
        target_language: target_language,
        source_language: "en",
        context:         context
      })

      TranslationResult.new(
        translated_text: response[:translated_text],
        source_language: response[:source_language],
        target_language: response[:target_language],
        language_name:   response[:language_name]
      )
    end
  end
end
