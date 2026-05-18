module Demo
  class FamilyController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode
    before_action :require_parent_role

    def index
      render json: current_user.children.map { |child| serialize_child_dashboard(child) }
    end

    def chats
      children = current_user.children
      render json: children.map { |child| serialize_child_chats(child) }
    end

    private

    def serialize_child_dashboard(child)
      sports = child.season_memberships.active
        .joins(season: :sport)
        .includes(season: [ { sport: [ :sport_template, :school ] }, :season_memberships, :channels ])
        .map { |sm| serialize_child_sport(sm) }

      {
        id:         child.id,
        first_name: child.first_name,
        last_name:  child.last_name,
        sports:     sports
      }
    end

    def serialize_child_sport(sm)
      season   = sm.season
      sport    = season.sport
      template = sport.sport_template

      coaches = season.season_memberships.active
        .where(role: %w[head_coach assistant_coach])
        .includes(:user)
        .map { |c| { name: c.user.full_name, role: c.role } }

      ann_channel = season.channels.find { |ch| ch.name == "announcements" }
      announcements = if ann_channel
        Message.where(channel: ann_channel, deleted_at: nil)
          .order(created_at: :desc)
          .limit(5)
          .includes(:sender)
          .map { |a| { id: a.id, content: a.content, sender_name: a.sender.full_name, sent_at: a.created_at.iso8601 } }
      else
        []
      end

      {
        season_id:            season.id,
        sport_name:           "#{sport.gender.capitalize} #{template.name}",
        level:                sport.levels.first || "Varsity",
        school_name:          sport.school.name,
        season_name:          season.name,
        athletic_season:      template.athletic_season,
        coaches:              coaches,
        recent_announcements: announcements
      }
    end

    def require_parent_role
      return if current_user.season_memberships.parent.exists?
      render json: { error: "Not authorized" }, status: :forbidden
    end

    STAFF_ROLE_LABELS = {
      "head_coach"          => "Coach",
      "assistant_coach"     => "Coach",
      "athletic_director"   => "Athletic Dir.",
      "school_admin"        => "School Admin",
      "district_admin"      => "District Admin",
      "sports_commissioner" => "Commissioner",
      "super_admin"         => "Admin"
    }.freeze

    def serialize_child_chats(child)
      approved_request = ParentViewRequest
        .active_approval_for(current_user, child)
        .includes(:reviewed_by)
        .first

      latest_request = ParentViewRequest
        .where(parent: current_user, child: child)
        .order(created_at: :desc)
        .first

      conversations = DmConversation
        .where("participant_a_id = ? OR participant_b_id = ?", child.id, child.id)
        .includes(:direct_messages, season: { season_memberships: :user })
        .to_a
        .sort_by { |c| c.direct_messages.map(&:created_at).max || Time.at(0) }
        .reverse

      {
        child_id:         child.id,
        child_name:       child.full_name,
        child_first_name: child.first_name,
        access_request:   latest_request ? serialize_access_request(latest_request) : nil,
        conversations:    conversations.map { |conv| serialize_conversation(conv, child, approved_request) }
      }
    end

    def serialize_access_request(req)
      {
        id:          req.id,
        status:      req.status,
        child_id:    req.child_id,
        expires_at:  req.expires_at&.iso8601,
        reviewed_by: req.reviewed_by&.full_name
      }
    end

    def serialize_conversation(conv, child, approved_request)
      other_id   = conv.participant_a_id == child.id ? conv.participant_b_id : conv.participant_a_id
      other_sm   = conv.season.season_memberships.find { |sm| sm.user_id == other_id }
      staff_role = other_sm.present? ? STAFF_ROLE_LABELS[other_sm.role] : nil
      other_name = staff_role ? other_sm.user.full_name : "Student"

      is_peer = staff_role.nil?
      # Coach DMs are never shown to parents regardless of approval status.
      # Parents who have concerns contact the AD directly; the AD handles off-platform.
      flagged      = is_peer && conv.direct_messages.any? { |m|
        m.flag_action.present? && m.flag_action != "blocked"
      }
      show_content = is_peer && (flagged || approved_request.present?)

      messages = show_content ? conv.direct_messages
        .to_a
        .reject { |m| m.flag_action == "blocked" }
        .sort_by(&:created_at) : []

      access = if !is_peer
        { type: "coach" }
      elsif flagged
        { type: "flagged" }
      elsif approved_request
        {
          type:        "approved",
          expires_at:  approved_request.expires_at&.iso8601,
          approved_by: approved_request.reviewed_by&.full_name
        }
      else
        { type: "locked" }
      end

      {
        id:                conv.id,
        other_participant: { name: other_name, staff_role: staff_role },
        access:            access,
        last_message:      messages.last ? serialize_message(messages.last, child, other_name) : nil,
        messages:          messages.map { |m| serialize_message(m, child, other_name) }
      }
    end

    def serialize_message(msg, child, other_name)
      is_child = msg.sender_id == child.id
      {
        id:       msg.id,
        content:  msg.content,
        sender:   is_child ? child.first_name : other_name,
        sent_at:  msg.created_at.iso8601,
        is_child: is_child
      }
    end
  end
end
