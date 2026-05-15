module Admin
  class CalendarEventsController < ApplicationController
    before_action :set_sport
    before_action :set_event, only: [ :update, :destroy ]
    before_action :require_write_access!, only: [ :create, :update, :destroy ]

    def index
      events = @sport.calendar_events.order(:starts_at)
      render json: events.map { |e| serialize(e) }
    end

    def create
      event = @sport.calendar_events.create!(event_params.merge(created_by: current_user))
      render json: serialize(event), status: :created
    end

    def update
      @event.update!(event_params)
      render json: serialize(@event)
    end

    def destroy
      @event.destroy!
      head :no_content
    end

    private

    def set_sport
      @sport = Sport.active.find_by(id: params[:sport_id])
      render json: { error: "Sport not found" }, status: :not_found unless @sport
    end

    def set_event
      @event = @sport.calendar_events.find(params[:id])
    end

    def require_write_access!
      return if commissioner_for?(@sport) || admin_for?(@sport)

      render json: { error: "Forbidden" }, status: :forbidden
    end

    def commissioner_for?(sport)
      current_user.sport_commissionerships.active.exists?(
        sport_template_id: sport.sport_template_id,
        district_id:       sport.school.district_id
      )
    end

    def admin_for?(sport)
      current_user.institution_roles.exists?(
        role:      %w[super_admin district_admin school_admin athletic_director],
        school_id: [ sport.school_id, nil ]
      )
    end

    def serialize(event)
      annotation = coach_annotation_for(event)
      {
        id:         event.id,
        sport_id:   event.sport_id,
        title:      event.title,
        event_type: event.event_type,
        home_away:  event.home_away,
        location:   event.location,
        opponent:   event.opponent,
        starts_at:  event.starts_at,
        ends_at:    event.ends_at,
        notes:      event.notes,
        status:     event.status,
        annotation: annotation ? { warmup_time: annotation.warmup_time, team_notes: annotation.team_notes } : nil
      }
    end

    def coach_annotation_for(event)
      season = current_user.season_memberships.active.where(role: :head_coach)
                           .joins(:season).where(seasons: { sport_id: @sport.id })
                           .first&.season
      return nil unless season

      event.team_event_annotations.find_by(season: season)
    end

    def event_params
      params.permit(:title, :event_type, :home_away, :location, :opponent,
                    :starts_at, :ends_at, :notes, :status)
    end
  end
end
