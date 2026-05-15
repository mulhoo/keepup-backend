module Demo
  class AnnouncementsController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode

    def index
      channel_ids = accessible_announcement_channels.pluck(:id)
      messages = Message
        .where(channel_id: channel_ids, deleted_at: nil)
        .includes(:sender, channel: { season: { sport: [ :school, :sport_template ] } })
        .order(created_at: :desc)
        .limit(50)

      render json: messages.map { |m| serialize(m) }
    end

    def create
      content = params[:content].to_s.strip
      return render json: { error: "Content is required" }, status: :unprocessable_entity if content.blank?

      channels = target_channels  # returns Array, already deduped to one channel per sport

      return render json: { error: "No matching sports found" }, status: :unprocessable_entity if channels.empty?

      channels.each { |ch| Message.create!(channel: ch, sender: current_user, content: content) }

      render json: {
        sent_count: channels.count,
        sports:     channels.map { |ch| sport_label(ch) }
      }
    end

    private

    def require_demo_mode
      render json: { error: "Not found" }, status: :not_found unless Rails.application.config.demo_mode
    end

    def accessible_announcement_channels
      role = current_user.institution_roles.first
      return Channel.none unless role

      base = Channel
        .joins(season: { sport: [ :school, :sport_template ] })
        .where(name: "announcements", channel_type: :broadcast)

      if role.super_admin?
        base
      elsif role.district_admin?
        base.where(schools: { district_id: role.district_id })
      elsif role.school_admin? || role.athletic_director?
        base.where(sports: { school_id: role.school_id })
      else
        season_ids = current_user.season_memberships.where(status: :active).pluck(:season_id)
        base.where(seasons: { id: season_ids })
      end
    end

    def target_channels
      base = accessible_announcement_channels

      if params[:sport_ids].present?
        sport_ids = Array(params[:sport_ids]).map(&:to_i)
        base = base.where(sports: { id: sport_ids })
      end

      if params[:school_ids].present?
        school_ids = Array(params[:school_ids]).map(&:to_i)
        base = base.where(schools: { id: school_ids })
      end

      if params[:athletic_season].present?
        base = base.where(sport_templates: { athletic_season: params[:athletic_season] })
      end

      # One channel per sport — pick the most recent season (highest id)
      seen = {}
      base
        .order(id: :desc)
        .includes(season: { sport: [ :school, :sport_template ] })
        .each_with_object([]) do |ch, uniq|
          sport_id = ch.season.sport_id
          next if seen[sport_id]
          seen[sport_id] = true
          uniq << ch
        end
    end

    def serialize(msg)
      sport  = msg.channel.season.sport
      school = sport.school
      {
        id:          msg.id,
        content:     msg.content,
        sender:      { id: msg.sender_id, name: "#{msg.sender.first_name} #{msg.sender.last_name}" },
        sport_name:  sport.name,
        gender:      sport.gender,
        school_name: school.name,
        created_at:  msg.created_at.iso8601
      }
    end

    def sport_label(ch)
      sport = ch.season.sport
      "#{sport.gender.capitalize} #{sport.name}"
    end
  end
end
