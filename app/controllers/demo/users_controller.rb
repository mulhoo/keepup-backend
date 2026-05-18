module Demo
  class UsersController < ApplicationController
    before_action :require_demo_mode

    # GET /demo/me
    def show
      render json: user_json(current_user)
    end

    # GET /demo/users/:id
    def profile
      user = User.active.find_by(id: params[:id])
      return render json: { error: "Not found" }, status: :not_found unless user
      return render json: { error: "Not found" }, status: :not_found unless viewable_by_current_user?(user)

      role = nil
      if params[:season_id].present?
        role = user.season_memberships.active.find_by(season_id: params[:season_id])&.role
      end

      render json: {
        id:                user.id,
        first_name:        user.first_name,
        last_name:         user.last_name,
        email:             user.email,
        profile_photo_url: user.profile_photo_url,
        pronouns:          user.pronouns,
        role:              role,
        name_display:      user.name_display
      }
    end

    # PATCH /demo/me/accessibility
    def accessibility
      merged = current_user.accessibility.merge(accessibility_params.to_h)
      current_user.update!(accessibility: merged)
      render json: { accessibility: current_user.accessibility }
    end

    # PATCH /demo/me/preferences
    def preferences
      prefs = preferences_params.to_h
      pronouns_provided = prefs.key?("pronouns")
      pronouns = prefs.delete("pronouns")
      lang_provided = prefs.key?("preferred_language")
      lang = prefs.delete("preferred_language")
      attrs = { preferences: (current_user.preferences || {}).merge(prefs) }
      attrs[:pronouns]           = pronouns.presence if pronouns_provided
      attrs[:preferred_language] = lang.presence     if lang_provided
      current_user.update!(attrs)
      render json: { preferences: current_user.preferences, pronouns: current_user.pronouns, preferred_language: current_user.preferred_language }
    end

    private

    def accessibility_params
      params.require(:accessibility).permit(:font_size)
    end

    def preferences_params
      params.require(:preferences).permit(:default_district_key, :name_display, :pronouns, :preferred_language)
    end

    def user_json(user)
      {
        id:                 user.id,
        first_name:         user.first_name,
        last_name:          user.last_name,
        email:              user.email,
        pronouns:           user.pronouns,
        preferred_language: user.preferred_language,
        accessibility:      user.accessibility
      }
    end

    def require_demo_mode
      render json: { error: "Not found" }, status: :not_found unless Rails.application.config.demo_mode
    end

    def viewable_by_current_user?(user)
      return true if user.id == current_user.id

      viewer_roles = current_user.institution_roles.pluck(:role).map(&:to_s)
      return true if (viewer_roles & %w[super_admin district_admin school_admin athletic_director]).any?

      viewer_season_ids = current_user.season_memberships.active.pluck(:season_id)
      user.season_memberships.active.where(season_id: viewer_season_ids).exists?
    end
  end
end
