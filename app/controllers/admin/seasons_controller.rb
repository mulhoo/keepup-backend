module Admin
  class SeasonsController < ApplicationController
    include SeasonAccessible

    def index
      seasons = accessible_seasons.order(:name)
      render json: seasons.map { |s| serialize(s) }
    end

    private

    def serialize(s)
      {
        id:          s.id,
        name:        s.name,
        school_year: s.school_year,
        sport_name:  s.sport.name,
        school_name: s.school.name,
        status:      s.status
      }
    end
  end
end
