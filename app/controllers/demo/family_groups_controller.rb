module Demo
  class FamilyGroupsController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode
    before_action :require_parent_role

    def index
      groups = Channel.family_group
        .joins(:channel_memberships)
        .where(channel_memberships: { user_id: current_user.id })
        .includes(:season, channel_memberships: :user)
        .order(updated_at: :desc)

      parent_seasons = current_user
        .season_memberships.parent.active
        .includes(season: :sport)
        .map(&:season)

      render json: {
        groups:         groups.map { |g| serialize_group(g) },
        parent_seasons: parent_seasons.map { |s| serialize_season_for_form(s) }
      }
    end

    def create
      season = Season.find_by(id: params[:season_id])
      return render json: { error: "Season not found" }, status: :not_found unless season

      unless current_user.season_memberships.parent.active.exists?(season:)
        return render json: { error: "Not a parent in this season" }, status: :forbidden
      end

      name = params[:name].to_s.strip
      return render json: { error: "Name can't be blank" }, status: :unprocessable_entity if name.blank?

      member_ids = (Array(params[:member_ids]).map(&:to_i) + [ current_user.id ]).uniq

      error = validate_student_coverage(member_ids, season)
      return render json: { error: }, status: :unprocessable_entity if error

      group = nil
      ActiveRecord::Base.transaction do
        group = Channel.create!(
          season:           season,
          name:             name,
          channel_type:     :family_group,
          created_by:       current_user,
          system_generated: false,
          active:           true,
        )
        member_ids.each { |uid| ChannelMembership.create!(channel: group, user_id: uid) }
      end

      render json: serialize_group(group), status: :created
    end

    private

    def require_parent_role
      return if current_user.season_memberships.parent.exists?
      render json: { error: "Not authorized" }, status: :forbidden
    end

    def validate_student_coverage(member_ids, season)
      memberships    = season.season_memberships.where(user_id: member_ids).includes(:user)
      student_sms    = memberships.select(&:student?)
      parent_user_ids = memberships.select(&:parent?).map(&:user_id)

      student_sms.each do |sm|
        parent_ids = sm.user.parents.pluck(:id)
        unless (parent_ids & parent_user_ids).any?
          return "#{sm.user.first_name} doesn't have a parent in the group — add their parent first"
        end
      end
      nil
    end

    def serialize_group(group)
      members   = group.channel_memberships.map(&:user)
      sm_map    = group.season.season_memberships.where(user_id: members.map(&:id)).index_by(&:user_id)
      last_msg  = group.messages.where.not(flag_action: "blocked").order(created_at: :desc).first

      {
        id:           group.id,
        name:         group.name,
        season:       { id: group.season_id, name: group.season.name },
        member_count: members.size,
        members:      members.map { |u|
          { id: u.id, name: u.full_name, first_name: u.first_name, role: sm_map[u.id]&.role || "unknown" }
        },
        last_message: last_msg ? {
          content: last_msg.content,
          sender:  last_msg.sender.first_name,
          sent_at: last_msg.created_at.iso8601
        } : nil
      }
    end

    def serialize_season_for_form(season)
      memberships = season.season_memberships.active
        .where(role: %w[parent student])
        .includes(:user)

      {
        id:   season.id,
        name: season.name,
        eligible_members: memberships
          .reject { |sm| sm.user_id == current_user.id }
          .map { |sm|
            {
              id:        sm.user_id,
              name:      sm.user.full_name,
              role:      sm.role,
              child_ids: sm.parent? ? sm.user.children.pluck(:id) : []
            }
          }
      }
    end
  end
end
