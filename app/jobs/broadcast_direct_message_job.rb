class BroadcastDirectMessageJob < ApplicationJob
  queue_as :default

  def perform(direct_message_id)
    dm = DirectMessage.includes(:sender, :dm_conversation).find_by(id: direct_message_id)
    return unless dm

    return if dm.flag_action == "blocked"

    payload = {
      type:            "new_direct_message",
      id:              dm.id,
      conversation_id: dm.dm_conversation_id,
      sender_id:       dm.sender_id,
      sender_name:     dm.sender.full_name,
      content:         dm.flag_action == "held" ? nil : dm.content,
      flag_action:     dm.flag_action,
      created_at:      dm.created_at.iso8601
    }

    ActionCable.server.broadcast("dm_conversation:#{dm.dm_conversation_id}", payload)

    if dm.flag_action == "held"
      ActionCable.server.broadcast("user_feed:#{dm.sender_id}", {
        type:            "dm_held",
        id:              dm.id,
        conversation_id: dm.dm_conversation_id,
        content:         dm.content,
        flag_action:     "held",
        created_at:      dm.created_at.iso8601
      })
    end
  end
end
