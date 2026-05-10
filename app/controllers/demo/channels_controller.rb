module Demo
  class ChannelsController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode

    def index
      channels = policy_scope(Channel).includes(season: :sport)

      render json: channels.map { |ch|
        {
          id:               ch.id,
          name:             ch.name,
          channel_type:     ch.channel_type,
          sport:            ch.season.sport.name,
          season:           ch.season.name,
          system_generated: ch.system_generated
        }
      }
    end

    private

    def require_demo_mode
      render json: { error: "Not found" }, status: :not_found unless Rails.application.config.demo_mode
    end
  end
end
