module Admin
  class EventAnnotationsController < ApplicationController
    def annotate
      event  = CalendarEvent.find(params[:id])
      season = head_coach_season_for(event.sport)

      return render json: { error: "Not a head coach for this sport" }, status: :forbidden unless season

      annotation = event.team_event_annotations.find_or_initialize_by(season: season)
      annotation.assign_attributes(annotation_params.merge(updated_by: current_user))
      annotation.save!

      render json: { warmup_time: annotation.warmup_time, team_notes: annotation.team_notes }
    end

    private

    def head_coach_season_for(sport)
      current_user.season_memberships.active.where(role: :head_coach)
                  .joins(:season).where(seasons: { sport_id: sport.id })
                  .first&.season
    end

    def annotation_params
      params.permit(:warmup_time, :team_notes)
    end
  end
end
