module DemoGuard
  extend ActiveSupport::Concern

  BLOCKED_ACTIONS = {
    "channels"        => %w[destroy],
    "sports"          => %w[destroy],
    "season_memberships" => %w[destroy],
    "users"           => %w[update destroy],
    "institution_roles" => %w[destroy]
  }.freeze

  included do
    before_action :enforce_demo_restrictions, if: :demo_session?
  end

  private

  def require_demo_mode
    render json: { error: "Not found" }, status: :not_found unless Rails.application.config.demo_mode
  end

  # Returns the school if the current user is an athletic director, nil otherwise.
  def ad_school
    current_user.institution_roles.find_by(role: :athletic_director)&.school
  end

  # "2025-26" style string for the school year that contains the given date.
  def current_school_year(date = Date.current)
    year = date.month >= 8 ? date.year : date.year - 1
    "#{year}-#{(year + 1).to_s[-2..]}"
  end

  def enforce_demo_restrictions
    blocked = BLOCKED_ACTIONS[controller_name]&.include?(action_name)
    destructive_verb = request.delete? && !request.get?

    if blocked || destructive_verb
      render json: {
        error: "This action is disabled in demo mode.",
        demo: true
      }, status: :forbidden
    end
  end
end
