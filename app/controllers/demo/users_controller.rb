module Demo
  class UsersController < ApplicationController
    before_action :require_demo_mode

    # GET /demo/me
    def show
      render json: user_json(current_user)
    end

    # PATCH /demo/me/accessibility
    def update_accessibility
      merged = current_user.accessibility.merge(accessibility_params.to_h)
      current_user.update!(accessibility: merged)
      render json: { accessibility: current_user.accessibility }
    end

    # PATCH /demo/me/preferences
    def update_preferences
      merged = current_user.preferences.merge(preferences_params.to_h)
      current_user.update!(preferences: merged)
      render json: { preferences: current_user.preferences }
    end

    private

    def accessibility_params
      params.require(:accessibility).permit(:font_size)
    end

    def preferences_params
      params.require(:preferences).permit(:default_district_key)
    end

    def user_json(user)
      {
        id:            user.id,
        first_name:    user.first_name,
        last_name:     user.last_name,
        email:         user.email,
        accessibility: user.accessibility,
      }
    end

    def require_demo_mode
      render json: { error: "Not found" }, status: :not_found unless Rails.application.config.demo_mode
    end
  end
end
