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
