module Demo
  class NotificationsController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode

    def index
      safety  = Notification.where(recipient: current_user).recent.limit(30)
      mod     = ModerationNotification.where(recipient: current_user)
                                      .order(created_at: :desc).limit(20)
                                      .includes(:recipient)

      notifications = [
        *safety.map { |n| serialize_safety(n) },
        *mod.map    { |n| serialize_moderation(n) }
      ].sort_by { |n| n[:created_at] }.reverse.first(30)

      render json: notifications
    end

    def mark_all_read
      now = Time.current
      Notification.where(recipient: current_user, read_at: nil).update_all(read_at: now)
      ModerationNotification.where(recipient: current_user, read_at: nil).update_all(read_at: now)
      render json: { ok: true }
    end

    def update
      prefix, raw_id = params[:id].to_s.split("_", 2)

      case prefix
      when "n"
        notif = Notification.find_by(id: raw_id, recipient: current_user)
        if notif
          notif.mark_read!
          return render json: serialize_safety(notif)
        end
      when "m"
        mod = ModerationNotification.find_by(id: raw_id, recipient: current_user)
        if mod
          mod.update!(read_at: Time.current)
          return render json: serialize_moderation(mod)
        end
      end

      render json: { error: "Not found" }, status: :not_found
    end

    private

    def serialize_safety(notif)
      meta = notif.parsed_metadata
      {
        id:                "n_#{notif.id}",
        notification_type: notif.notification_type,
        title:             notif.title,
        body:              notif.body,
        read:              notif.read?,
        read_at:           notif.read_at&.iso8601,
        created_at:        notif.created_at.iso8601,
        metadata:          meta
      }
    end

    def serialize_moderation(notif)
      sport   = notif.sport
      school  = sport&.school
      channel = notif.message&.channel
      is_district_admin = current_user.institution_roles.where(role: :district_admin).exists?
      body    = "Flagged content in #{sport&.name || 'a sport'}"
      body   += " at #{school.name}"         if school && is_district_admin
      body   += " — #{channel.name} channel" if channel
      {
        id:                "m_#{notif.id}",
        notification_type: notif.notification_type,
        title:             moderation_title(notif),
        body:              body,
        read:              notif.read_at.present?,
        read_at:           notif.read_at&.iso8601,
        created_at:        notif.created_at.iso8601,
        metadata: {
          "flagged_content" => {
            "type"       => notif.message_id ? "channel_message" : "direct_message",
            "id"         => notif.message_id || notif.direct_message_id,
            "channel_id" => notif.message&.channel_id
          }
        }
      }
    end

    def moderation_title(notif)
      case notif.notification_type
      when "severe_alert"        then "Severe content flagged"
      when "questionable_review" then "Content needs review"
      else "Moderation alert"
      end
    end
  end
end
