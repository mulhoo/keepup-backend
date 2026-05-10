class MessageTranslation < ApplicationRecord
  belongs_to :message

  validates :language, :translated_text, presence: true
  validates :language, uniqueness: { scope: :message_id }
end
