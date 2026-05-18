module Demo
  class CoachConversationsController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode
    before_action :require_parent_role

    def alert_ad
      conv = DmConversation.includes(season: { sport: :school }).find(params[:id])

      child_id = [ conv.participant_a_id, conv.participant_b_id ]
        .find { |id| current_user.children.exists?(id) }
      return render json: { error: "Not found" }, status: :not_found unless child_id

      child  = User.find(child_id)
      school = conv.season&.sport&.school
      return render json: { error: "Could not determine school" }, status: :unprocessable_entity unless school

      ad_roles = InstitutionRole
        .where(school: school, role: %i[athletic_director school_admin])
        .includes(:user)

      note        = params[:note].to_s.strip
      notified_at = Time.current
      body        = "#{current_user.full_name} has flagged a private coach conversation involving #{child.first_name} for your review."
      body       += "\n\nParent's note: #{note}" if note.present?

      ad_roles.each do |role|
        Notification.create!(
          recipient_id:      role.user_id,
          notification_type: "parent_coach_alert",
          title:             "Parent concern — coach conversation",
          body:              body,
          metadata:          { conversation_id: conv.id, child_id: child.id, parent_id: current_user.id, note: note }.to_json,
        )
      end

      Activity.create!(
        event_type:  :parent_coach_concern,
        actor:       current_user,
        school:      school,
        occurred_at: notified_at,
        metadata:    {
          child_name:   child.full_name,
          parent_name:  current_user.full_name,
          note:         note.presence,
        }
      )

      render json: {
        notified_at: notified_at.iso8601,
        ad_count:    ad_roles.size,
      }
    end

    private

    def require_parent_role
      return if current_user.season_memberships.parent.exists?
      render json: { error: "Not authorized" }, status: :forbidden
    end
  end
end
