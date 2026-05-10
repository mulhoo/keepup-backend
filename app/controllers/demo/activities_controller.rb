module Demo
  class ActivitiesController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode
    before_action :require_activity, only: %i[notify_parents notify_ad notify_district_admin]

    def index
      activities = policy_scope(Activity).limit(50).includes(:actor, :season)
      render json: activities.map { |a| serialize(a) }
    end

    def notify_parents
      authorize @activity, :notify_parents?

      message = @activity.subject
      return render json: { error: "Not a message activity" }, status: :unprocessable_entity unless message.is_a?(Message)

      parents = message.sender.parents.where(active: true)

      @activity.update!(metadata: @activity.metadata.merge(
        "parents_notified_at"    => Time.current.iso8601,
        "parents_notified_count" => parents.count,
        "parents_notified_by"    => current_user.full_name
      ))

      render json: {
        notified:     parents.map { |p| { name: p.full_name } },
        notified_at:  @activity.metadata["parents_notified_at"]
      }
    end

    def notify_district_admin
      authorize @activity, :notify_district_admin?

      school          = @activity.season.school
      district_admin  = school.district.institution_roles.district_admin.first&.user
      return render json: { error: "No district admin found" }, status: :not_found unless district_admin

      # Determine peer: the other school-level authority who is CC'd
      user_is_ad = current_user.institution_roles.athletic_director.exists?(school:)
      peer = if user_is_ad
        InstitutionRole.school_admin.find_by(school:)&.user
      else
        InstitutionRole.athletic_director.find_by(school:)&.user
      end

      user_role_label = user_is_ad ? "athletic_director" : "school_admin"

      @activity.update!(metadata: @activity.metadata.merge(
        "district_notified_at"      => Time.current.iso8601,
        "district_notified_by_name" => current_user.full_name,
        "district_notified_by_role" => user_role_label,
        "peer_notified_name"        => peer&.full_name
      ))

      render json: {
        notified:          { name: district_admin.full_name },
        peer_notified:     peer ? { name: peer.full_name } : nil,
        notified_at:       @activity.metadata["district_notified_at"]
      }
    end

    def notify_ad
      authorize @activity, :notify_ad?

      ad = InstitutionRole.athletic_director.find_by(school: @activity.season.school)&.user
      return render json: { error: "No athletic director found for this sport" }, status: :not_found unless ad

      @activity.update!(metadata: @activity.metadata.merge(
        "ad_notified_at"   => Time.current.iso8601,
        "ad_notified_name" => ad.full_name,
        "ad_notified_by"   => current_user.full_name
      ))

      render json: {
        notified:    { name: ad.full_name },
        notified_at: @activity.metadata["ad_notified_at"]
      }
    end

    private

    def require_demo_mode
      render json: { error: "Not found" }, status: :not_found unless Rails.application.config.demo_mode
    end

    def require_activity
      @activity = Activity.find_by(id: params[:id])
      render json: { error: "Not found" }, status: :not_found unless @activity
    end

    def serialize(activity)
      m = activity.metadata
      {
        id:                  activity.id,
        event_type:          activity.event_type,
        occurred_at:         activity.occurred_at.iso8601,
        summary:             summary_for(activity),
        actor:               activity.actor ? { name: activity.actor.full_name } : nil,
        tier:                m["tier"],
        sport:               m["sport"],
        season:              m["season"],
        channel:             m["channel"],
        flag_action:         m["flag_action"],
        flag_reason:         m["flag_reason"],
        accessed_user_name:  m["accessed_user_name"],
        accessor_role:       m["accessor_role"],
        parents_notified_at:        m["parents_notified_at"],
        ad_notified_at:             m["ad_notified_at"],
        ad_notified_name:           m["ad_notified_name"],
        district_notified_at:       m["district_notified_at"],
        district_notified_by_name:  m["district_notified_by_name"],
        district_notified_by_role:  m["district_notified_by_role"],
        peer_notified_name:         m["peer_notified_name"]
      }
    end

    def summary_for(activity)
      m = activity.metadata
      case activity.event_type
      when "message_flagged"
        tier    = m["tier"]&.capitalize || "Flagged"
        sport   = m["sport"] || "Unknown sport"
        channel = m["channel"] || "channel"
        "#{tier} content in #{sport} — #{channel}"
      when "data_accessed"
        actor  = activity.actor&.full_name || "Unknown"
        role   = m["accessor_role"]&.humanize || "Staff"
        target = m["accessed_user_name"] || "a student"
        "#{actor} (#{role}) — viewed #{target}'s data"
      end
    end
  end
end
