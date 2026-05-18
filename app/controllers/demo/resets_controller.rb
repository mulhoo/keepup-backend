module Demo
  class ResetsController < Demo::ApplicationController
    before_action :require_demo_mode
    before_action :require_reset_key

    # POST /demo/reset
    # Enqueues a full database truncate + reseed.
    # Pass reset_key in the request body or as a query param.
    def create
      ResetDemoDatabaseJob.perform_now
      render json: { ok: true, message: "Database reset complete." }
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end

    private

    def require_reset_key
      expected = ENV["DEMO_RESET_KEY"].presence
      return if expected.nil? # no key configured → open in dev/staging

      provided = params[:reset_key].to_s
      unless provided.present? && ActiveSupport::SecurityUtils.secure_compare(provided, expected)
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end
  end
end
