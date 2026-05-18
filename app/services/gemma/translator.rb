module Gemma
  # Translates text via the self-hosted FastAPI /translate endpoint.
  # Gemma runs on our own infrastructure — no third-party egress, safe for student content.
  # target_language is a free-form language name (e.g. "French", "Arabic", "Japanese").
  class Translator
    TranslationResult = Data.define(:translated_text, :source_language, :target_language, :language_name)

    def self.translate(text:, target_language:, context: "message")
      new.translate(text:, target_language:, context:)
    end

    def translate(text:, target_language:, context: "message")
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
        language_name:   response[:language_name] || target_language
      )
    end
  end
end
