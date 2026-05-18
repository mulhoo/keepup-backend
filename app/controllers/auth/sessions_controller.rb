module Auth
  class SessionsController < ApplicationController
    def show
      render json: session_payload(current_user)
    end

    private

    def session_payload(user)
      {
        user: {
          id:            user.id,
          first_name:    user.first_name,
          last_name:     user.last_name,
          email:         user.email,
          theme:         user.effective_theme&.color_palette,
          managing_role: user.institution_roles.order(:role).first&.role
        }
      }
    end
  end
end
