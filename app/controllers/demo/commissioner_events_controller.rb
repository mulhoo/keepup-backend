module Demo
  class CommissionerEventsController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode
    before_action :require_commissioner_role
    before_action :set_event, only: [ :update, :notify ]

    def index
      events = CommissionerEvent
        .where(sport_template: managed_templates, district: commissioner_districts)
        .order(:starts_at)
        .map { |e| serialize(e) }
      render json: events
    end

    def update
      @event.update!(event_params)
      render json: serialize(@event)
    end

    def notify
      render json: { sent: true }
    end

    private

    def require_commissioner_role
      return if managed_templates.any?
      render json: { error: "Forbidden" }, status: :forbidden
    end

    def managed_templates
      @managed_templates ||= current_user.sport_commissionerships.active
                               .map(&:sport_template)
    end

    def commissioner_districts
      @commissioner_districts ||= current_user.sport_commissionerships.active
                                    .map(&:district)
    end

    def set_event
      @event = CommissionerEvent.find_by(
        id:             params[:id],
        sport_template: managed_templates,
        district:       commissioner_districts
      )
      render json: { error: "Not found" }, status: :not_found unless @event
    end

    def event_params
      params.permit(:title, :starts_at, :ends_at, :venue, :status, :notes, matchup_pairs: [ :home_school_id, :away_school_id ])
    end

    def serialize(event)
      coaches = coaches_for(event)
      {
        id:             event.id,
        title:          event.title,
        event_type:     event.event_type,
        sport_name:     event.sport_template.name,
        starts_at:      event.starts_at.iso8601,
        ends_at:        event.ends_at&.iso8601,
        venue:          event.venue,
        teams:          event.teams,
        matchup_pairs:  event.matchup_pairs,
        coaches:        coaches,
        status:         event.status,
        has_results:    event.has_results,
        result_summary: event.result_summary,
        notes:          event.notes || "",
      }
    end

    def coaches_for(event)
      school_ids = event.teams.map { |t| t["school_id"] }.uniq.compact
      return [] if school_ids.empty?

      SeasonMembership.active
        .where(role: %w[head_coach assistant_coach])
        .joins(season: { sport: :school })
        .where(sports: { school_id: school_ids, sport_template: managed_templates })
        .includes(:user, season: { sport: :school })
        .map do |sm|
          {
            name:        sm.user.full_name,
            role:        sm.role,
            email:       sm.user.email,
            school_name: sm.season.sport.school.name,
          }
        end
    end
  end
end
