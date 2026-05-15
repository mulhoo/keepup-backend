module Demo
  class ParentViewRequestsController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode
    before_action :require_parent_role, only: [ :create ]
    before_action :require_ad_role,     only: [ :index, :approve, :deny ]

    def index
      requests = ParentViewRequest.pending
        .includes(:parent, :child)
        .order(created_at: :asc)
      render json: requests.map { |r| serialize_for_ad(r) }
    end

    def create
      child = current_user.children.find_by(id: params[:child_id])
      return render json: { error: "Not found" }, status: :not_found unless child

      # Return existing open request rather than duplicating
      existing = ParentViewRequest
        .where(parent: current_user, child: child)
        .where(status: %w[pending approved])
        .where("expires_at IS NULL OR expires_at > ?", Time.current)
        .first
      return render json: serialize_for_parent(existing), status: :ok if existing

      req = ParentViewRequest.create!(
        parent: current_user,
        child:  child,
        reason: params[:reason].to_s.strip,
      )
      render json: serialize_for_parent(req), status: :created
    end

    def approve
      req = ParentViewRequest.pending.find(params[:id])
      req.approve!(current_user)
      render json: serialize_for_ad(req)
    end

    def deny
      req = ParentViewRequest.pending.find(params[:id])
      req.deny!(current_user)
      render json: serialize_for_ad(req)
    end

    private

    def require_parent_role
      return if current_user.season_memberships.parent.exists?
      render json: { error: "Not authorized" }, status: :forbidden
    end

    def require_ad_role
      allowed = %w[athletic_director school_admin district_admin super_admin]
      return if current_user.institution_roles.where(role: allowed).exists?
      render json: { error: "Not authorized" }, status: :forbidden
    end

    def serialize_for_parent(req)
      {
        id:         req.id,
        status:     req.status,
        child_id:   req.child_id,
        expires_at: req.expires_at&.iso8601
      }
    end

    def serialize_for_ad(req)
      {
        id:          req.id,
        status:      req.status,
        parent_name: req.parent.full_name,
        child_name:  req.child.full_name,
        reason:      req.reason,
        created_at:  req.created_at.iso8601,
        expires_at:  req.expires_at&.iso8601
      }
    end
  end
end
