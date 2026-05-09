class MessageThread < ApplicationRecord
  belongs_to :channel
  belongs_to :parent_message, class_name: "Message"
  has_many :messages, dependent: :destroy

  def increment_reply_count!
    with_lock do
      update!(reply_count: reply_count + 1, last_reply_at: Time.current)
    end
  end
end
