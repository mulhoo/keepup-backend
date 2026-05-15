module Demo
  class VenuesController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode
    before_action :require_commissioner_role
    before_action :set_venue, only: [ :update, :destroy, :set_closed ]

    def index
      venues = Venue.order(:name).map { |v| serialize(v) }
      render json: venues
    end

    def create
      venue = Venue.new(venue_params)
      venue.school = School.find_by(id: params[:school_id]) if params[:school_id]
      venue.availability = params[:availability] || []
      venue.save!
      render json: serialize(venue), status: :created
    end

    def update
      @venue.update!(venue_params)
      @venue.availability = params[:availability] if params.key?(:availability)
      @venue.save!
      render json: serialize(@venue)
    end

    def destroy
      @venue.destroy!
      head :no_content
    end

    def set_closed
      @venue.update!(
        temporarily_closed: params[:closed],
        closed_reason:      params[:reason] || ""
      )
      render json: serialize(@venue)
    end

    private

    def require_commissioner_role
      return if current_user.sport_commissionerships.active.any?
      render json: { error: "Forbidden" }, status: :forbidden
    end

    def set_venue
      @venue = Venue.find(params[:id])
    end

    def venue_params
      params.permit(:name, :facility_type, :address, :school_id)
    end

    def serialize(venue)
      {
        id:                 venue.id,
        name:               venue.name,
        school_id:          venue.school_id,
        school_name:        venue.school&.name || "",
        facility_type:      venue.facility_type,
        address:            venue.address,
        availability:       venue.availability,
        temporarily_closed: venue.temporarily_closed,
        closed_reason:      venue.closed_reason,
      }
    end
  end
end
