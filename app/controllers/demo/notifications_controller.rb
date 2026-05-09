module Demo
  class NotificationsController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode

    def index
      notifs = ModerationNotification.where(recipient: current_user)
                                     .order(created_at: :desc)
                                     .limit(20)
                                     .includes(:recipient)

      render json: notifs.map { |n| serialize(n) }
    end

    def update
      notif = ModerationNotification.find_by(id: params[:id], recipient: current_user)
      return render json: { error: "Not found" }, status: :not_found unless notif

      notif.update!(read_at: Time.current)
      render json: serialize(notif)
    end

    private

    def require_demo_mode
      render json: { error: "Not found" }, status: :not_found unless Rails.application.config.demo_mode
    end

    def serialize(notif)
      sport = notif.sport
      {
        id:                notif.id,
        notification_type: notif.notification_type,
        recipient_role:    notif.recipient_role,
        read:              notif.read_at.present?,
        read_at:           notif.read_at&.iso8601,
        created_at:        notif.created_at.iso8601,
        sport:             sport&.name,
        flagged_content: {
          type:       notif.message_id ? "channel_message" : "direct_message",
          id:         notif.message_id || notif.direct_message_id,
          channel_id: notif.message&.channel_id
        }
      }
    end
  end
end
