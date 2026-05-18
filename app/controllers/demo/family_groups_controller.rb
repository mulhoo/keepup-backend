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

      # member_ids contains: other parent IDs + the creator's chosen child IDs
      explicit_ids = Array(params[:member_ids]).map(&:to_i)
      member_ids   = (explicit_ids + [ current_user.id ]).uniq

      my_child_ids      = season.season_memberships.active.student
                            .where(user_id: ParentStudentRelationship.where(parent_id: current_user.id).select(:student_id))
                            .pluck(:user_id).to_set
      season_parent_ids = season.season_memberships.active.parent.pluck(:user_id).to_set
      eligible_ids      = my_child_ids | season_parent_ids

      invalid = explicit_ids.reject { |id| id == current_user.id || eligible_ids.include?(id) }
      return render json: { error: "One or more members cannot be added" }, status: :unprocessable_entity if invalid.any?

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

    def add_members
      group = Channel.family_group
        .joins(:channel_memberships)
        .where(channel_memberships: { user_id: current_user.id })
        .includes(:season, channel_memberships: :user)
        .find(params[:id])

      season       = group.season
      existing_ids = group.channel_memberships.map(&:user_id).to_set
      new_ids      = Array(params[:member_ids]).map(&:to_i).uniq.reject { |id| existing_ids.include?(id) }

      return render json: serialize_group(group) if new_ids.empty?

      my_child_ids     = season.season_memberships.active.student
        .where(user_id: ParentStudentRelationship.where(parent_id: current_user.id).select(:student_id))
        .pluck(:user_id).to_set
      season_parent_ids = season.season_memberships.active.parent.pluck(:user_id).to_set
      eligible_ids      = my_child_ids | season_parent_ids

      invalid = new_ids.reject { |id| eligible_ids.include?(id) }
      return render json: { error: "One or more members cannot be added" }, status: :unprocessable_entity if invalid.any?

      new_ids.each { |uid| ChannelMembership.find_or_create_by!(channel: group, user_id: uid) }

      render json: serialize_group(group.reload)
    end

    private

    def require_parent_role
      return if current_user.season_memberships.parent.exists?
      render json: { error: "Not authorized" }, status: :forbidden
    end

    def validate_student_coverage(member_ids, season)
      memberships     = season.season_memberships.where(user_id: member_ids).includes(:user)
      student_sms     = memberships.select(&:student?)
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
      members  = group.channel_memberships.map(&:user)
      sm_map   = group.season.season_memberships.where(user_id: members.map(&:id)).index_by(&:user_id)
      last_msg = group.messages.where.not(flag_action: "blocked").order(created_at: :desc).first

      member_ids = members.map(&:id)
      parent_ids = sm_map.select { |_, sm| sm.parent? }.keys

      # Map each parent to their children who are also in this group
      psrs = ParentStudentRelationship.where(parent_id: parent_ids, student_id: member_ids)
      member_map = members.index_by(&:id)
      parent_child_names = psrs.each_with_object({}) do |rel, h|
        child = member_map[rel.student_id]
        next unless child
        (h[rel.parent_id] ||= []) << child.first_name
      end

      {
        id:           group.id,
        name:         group.name,
        season:       { id: group.season_id, name: group.season.name },
        member_count: members.size,
        members:      members.map { |u|
          sm = sm_map[u.id]
          {
            id:         u.id,
            name:       u.full_name,
            first_name: u.first_name,
            role:       sm&.role || "unknown",
            child_name: parent_child_names[u.id]&.join(", "),
          }
        },
        last_message: last_msg ? {
          content: last_msg.content,
          sender:  last_msg.sender.first_name,
          sent_at: last_msg.created_at.iso8601
        } : nil
      }
    end

    def serialize_season_for_form(season)
      all_parent_sms = season.season_memberships.active.where(role: :parent).includes(:user)
      all_parent_ids = all_parent_sms.map(&:user_id)

      psrs = ParentStudentRelationship.where(parent_id: all_parent_ids)
      student_memberships = season.season_memberships.active.student
        .where(user_id: psrs.select(:student_id))
        .includes(:user)
      student_user_map = student_memberships.each_with_object({}) { |sm, h| h[sm.user_id] = sm.user }

      parent_to_child_names = psrs.each_with_object({}) do |rel, h|
        child = student_user_map[rel.student_id]
        next unless child
        (h[rel.parent_id] ||= []) << child.first_name
      end

      my_child_ids = psrs.select { |r| r.parent_id == current_user.id }.map(&:student_id).to_set
      my_children  = student_memberships
        .select { |sm| my_child_ids.include?(sm.user_id) }
        .map    { |sm| { id: sm.user_id, first_name: sm.user.first_name } }

      {
        id:          season.id,
        name:        season.name,
        my_children: my_children,
        eligible_members: all_parent_sms
          .reject { |sm| sm.user_id == current_user.id }
          .map { |sm|
            {
              id:         sm.user_id,
              name:       sm.user.full_name,
              child_name: parent_to_child_names[sm.user_id]&.join(", "),
              role:       "parent",
            }
          }
      }
    end
  end
end
