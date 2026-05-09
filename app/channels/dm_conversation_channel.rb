class DmConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = DmConversation.find_by(id: params[:conversation_id])

    unless conversation && conversation.participant?(current_user)
      return reject
    end

    stream_from "dm_conversation:#{conversation.id}"
  end

  def unsubscribed
  end
end
