module Demo
  class ChannelMembersController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode
    before_action :load_channel

    CHANNEL_ENROLLMENT = {
      "student"           => %w[general announcements athletes-only],
      "student_captain"   => %w[general announcements athletes-only],
      "parent"            => %w[general announcements parent-coaches],
      "head_coach"        => %w[general announcements coaches parent-coaches],
      "assistant_coach"   => %w[general announcements coaches parent-coaches],
      "athletic_director" => %w[general announcements parent-coaches]
    }.freeze

    # GET /demo/channels/:channel_id/members
    def index
      members = @channel.channel_memberships.includes(:user).map { |cm| serialize_member(cm.user) }

      result = { members: }

      if can_manage?
        in_channel = @channel.channel_memberships.pluck(:user_id).to_set
        addable = SeasonMembership.active
                                  .where(season: @channel.season)
                                  .where.not(user_id: in_channel)
                                  .includes(:user)
                                  .sort_by { |sm| sm.user.last_name }
                                  .map { |sm| serialize_member(sm.user) }
        result[:addable] = addable
      end

      render json: result
    end

    # POST /demo/channels/:channel_id/members
    def create
      return render json: { error: "Not authorized" }, status: :forbidden unless can_manage?

      user = User.find_by(id: params[:user_id])
      return render json: { error: "User not found" }, status: :not_found unless user

      unless SeasonMembership.active.exists?(user:, season: @channel.season)
        return render json: { error: "User is not a member of this season" }, status: :unprocessable_entity
      end

      auto_enroll!(user)
      render json: serialize_member(user), status: :created
    end

    private

    def load_channel
      @channel = Channel.active.find_by(id: params[:channel_id])
      return render json: { error: "Channel not found" }, status: :not_found unless @channel
      render json: { error: "Not authorized" }, status: :forbidden unless @channel.viewable_by?(current_user)
    end

    def auto_enroll!(user)
      role = member_role(user)
      names = CHANNEL_ENROLLMENT[role] || %w[general announcements]
      @channel.season.channels.active.where(name: names).each do |ch|
        ChannelMembership.find_or_create_by!(channel: ch, user:)
      end
    end

    def member_role(user)
      return "athletic_director" if user.institution_roles.athletic_director.exists?
      sm = user.season_memberships.find_by(season: @channel.season)
      return nil unless sm
      sm.student? && sm.is_captain? ? "student_captain" : sm.role
    end

    def can_manage?
      return true if ad_school&.id == @channel.season.school.id
      sm = current_user.season_memberships.active.find_by(season: @channel.season)
      sm&.role.in?(%w[head_coach assistant_coach])
    end

    def serialize_member(user)
      { id: user.id, name: user.full_name, role: member_role(user) }
    end
  end
end
