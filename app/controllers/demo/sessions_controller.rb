module Demo
  class SessionsController < ApplicationController
    skip_before_action :require_authentication
    before_action :require_demo_mode

    DEMO_ACCOUNTS = {
      "district_admin"      => "admin@hsd.edu",
      "school_admin"        => "schooladmin@ahs.edu",
      "athletic_director"   => "ad@ahs.edu",
      "sports_commissioner" => "jeff.swim@kingcounty.gov",
      "head_coach"          => "coach.swim@ahs.edu",
      "assistant_coach"     => "asst.swim@ahs.edu",
      "student_captain"     => "captain@ahs.student.edu",
      "student"             => "student1@ahs.student.edu",
      "parent"              => "parent1@example.com"
    }.freeze

    def destroy
      clear_auth_cookie
      load Rails.root.join("db/seeds.rb")
      head :no_content
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end

    def create
      role  = params[:role].to_s
      email = DEMO_ACCOUNTS[role]

      unless email
        return render json: {
          error: "Invalid demo role",
          valid_roles: DEMO_ACCOUNTS.keys
        }, status: :unprocessable_entity
      end

      user = User.active.find_by(email: email)
      return render json: { error: "Demo account not found — run db:seed first" }, status: :not_found unless user

      set_auth_cookie(generate_demo_token(user))
      render json: {
        demo: true,
        role: role,
        user: {
          id:            user.id,
          first_name:    user.first_name,
          last_name:     user.last_name,
          email:         user.email,
          accessibility: user.accessibility
        }
      }
    end

    private

    def require_demo_mode
      render json: { error: "Not found" }, status: :not_found unless Rails.application.config.demo_mode
    end

    def generate_demo_token(user)
      payload = {
        sub:  user.id,
        demo: true,
        role: params[:role],
        exp:  1.hour.from_now.to_i,
        iat:  Time.current.to_i
      }
      JWT.encode(payload, Rails.application.secret_key_base, "HS256")
    end
  end
end
