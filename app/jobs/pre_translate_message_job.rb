class PreTranslateMessageJob < ApplicationJob
  queue_as :default

  def perform(message_id)
    message = Message.includes(channel: { season: :season_memberships }).find_by(id: message_id)
    return unless message

    target_languages = User
      .joins(:season_memberships)
      .where(season_memberships: { season_id: message.channel.season_id })
      .where.not(preferred_language: [ nil, "" ])
      .distinct
      .pluck(:preferred_language)

    return if target_languages.empty?

    context        = message.channel.broadcast? ? "announcement" : "message"
    student_sender = message.sender.institution_roles.empty? &&
                     !message.sender.season_memberships
                       .where(season_id: message.channel.season_id)
                       .where(role: %w[head_coach assistant_coach])
                       .exists?

    target_languages.uniq.each do |lang|
      next if message.message_translations.exists?(language: lang)

      # Student content stays on self-hosted Gemma — no third-party egress (FERPA/COPPA).
      result = if student_sender
        Gemma::Translator.translate(text: message.content, target_language: lang, context:)
      elsif DeeplTranslator.available?
        DeeplTranslator.translate(text: message.content, target_language: lang)
      else
        Gemma::Translator.translate(text: message.content, target_language: lang, context:)
      end
      message.message_translations.find_or_create_by!(language: lang) do |t|
        t.translated_text = result.translated_text
      end
    rescue GemmaClient::ServiceUnavailable, StandardError => e
      Rails.logger.warn("[PreTranslateMessageJob] #{e.class}: #{e.message} for lang=#{lang}")
      break
    end
  end
end
