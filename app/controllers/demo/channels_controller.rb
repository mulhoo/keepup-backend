module Demo
  class ChannelsController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode

    def index
      memberships = current_user.sport_memberships.active.includes(sport: :channels)

      channels = memberships.flat_map do |sm|
        sm.sport.channels.active.select { |ch| ch.viewable_by?(current_user) }
      end

      render json: channels.map { |ch|
        {
          id:           ch.id,
          name:         ch.name,
          channel_type: ch.channel_type,
          sport:        ch.sport.name,
          pinned:       ch.pinned
        }
      }
    end

    private

    def require_demo_mode
      render json: { error: "Not found" }, status: :not_found unless Rails.application.config.demo_mode
    end
  end
end
