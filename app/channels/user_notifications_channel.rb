class UserNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "user_feed:#{current_user.id}"
  end

  def unsubscribed
  end
end
