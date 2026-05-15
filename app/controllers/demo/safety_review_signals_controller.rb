module Demo
  class SafetyReviewSignalsController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode
    before_action :require_coach_or_admin

    # GET /demo/safety_review_signals
    #
    # Returns aggregated approval rates grouped by category + sport_template + sender_role.
    # Devices sync this periodically and use it to tune Gemma's per-category thresholds —
    # no message content is ever stored or returned here.
    def index
      school_id = current_school_id
      return render json: { signals: [] } unless school_id

      rows = SafetyReviewSignal
        .recent
        .where(school_id: school_id)
        .group(:sport_template_id, :category, :sender_role)
        .select(
          :sport_template_id,
          :category,
          :sender_role,
          "COUNT(*) AS total",
          "SUM(CASE WHEN decision = 0 THEN 1 ELSE 0 END) AS approved_count"
        )

      render json: { signals: rows.map { |r| serialize_aggregate(r) } }
    end

    # POST /demo/safety_review_signals
    #
    # Called by the mobile app after a coach reviews a flagged message.
    # The device sends only the classification metadata — never the message content.
    def create
      school_id = current_school_id
      return render json: { error: "Could not determine school" }, status: :unprocessable_entity unless school_id

      signal = SafetyReviewSignal.new(
        school_id:        school_id,
        sport_template_id: params[:sport_template_id].presence,
        category:         params[:category].to_s.strip,
        decision:         params[:decision].to_s,
        sender_role:      params[:sender_role].to_s.strip,
        channel_type:     params[:channel_type].presence,
        gemma_confidence: params[:gemma_confidence].presence&.to_f,
      )

      unless signal.valid?
        return render json: { error: signal.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end

      signal.save!
      render json: { ok: true }, status: :created

    rescue ArgumentError => e
      # Catches invalid enum values like decision: "banana"
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def require_coach_or_admin
      allowed = %w[head_coach assistant_coach school_admin athletic_director district_admin super_admin]
      role = current_user.institution_roles.find_by(role: allowed) ||
             current_user.season_memberships.active.find_by(role: %w[head_coach assistant_coach])
      render json: { error: "Not authorized" }, status: :forbidden unless role
    end

    def current_school_id
      inst_role = current_user.institution_roles.first
      return inst_role.school_id if inst_role&.school_id.present?

      # Fall back to school via active season membership (coaches without an institution role)
      membership = current_user.season_memberships.active
                               .joins(season: { sport: :school })
                               .first
      membership&.season&.sport&.school_id
    end

    def serialize_aggregate(row)
      {
        sport_template_id: row.sport_template_id,
        category:          row.category,
        sender_role:       row.sender_role,
        approved_count:    row.approved_count.to_i,
        rejected_count:    row.total.to_i - row.approved_count.to_i,
        total:             row.total.to_i,
        approval_rate:     (row.approved_count.to_f / row.total).round(3)
      }
    end
  end
end
