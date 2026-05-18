module Demo
  class ChannelsController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode

    def index
      if params[:season_id].present?
        channels = channels_for_season(params[:season_id])
      else
        channels = policy_scope(Channel).includes(season: { sport: :school })
      end

      render json: channels.sort_by { |ch| ch.name.downcase }.map { |ch| serialize(ch) }
    end

    def mark_read
      ch = Channel.active.find_by(id: params[:id])
      return render json: {error: "Not found"}, status: :not_found unless ch
      return render json: {error: "Not authorized"}, status: :forbidden unless ch.viewable_by?(current_user)

      membership = ch.channel_memberships.find_by(user: current_user)
      membership&.update!(last_read_at: Time.current)
      render json: {ok: true}
    end

    def leave
      ch = Channel.active.find_by(id: params[:id])
      return render json: {error: "Not found"}, status: :not_found unless ch
      return render json: {error: "Cannot leave this channel"}, status: :unprocessable_entity unless leavable?(ch)

      ch.channel_memberships.find_by(user: current_user)&.destroy
      render json: {ok: true}
    end

    private

    def leavable?(ch)
      ch.channel_type.in?(%w[conversation broadcast])
    end

    def channels_for_season(season_id)
      season = Season.find_by(id: season_id)
      return [] unless season

      # ADs have no season_memberships; viewable_by? handles their access via channel_memberships.
      unless ad_school&.id == season.school.id
        membership = current_user.season_memberships.active.find_by(season: season)
        return [] unless membership
      end

      season.channels.active
            .includes(season: { sport: :school })
            .select { |ch| ch.viewable_by?(current_user) }
    end

    def serialize(ch)
      school      = ch.season.sport.school
      last_msg    = ch.messages.where(message_thread_id: nil).order(created_at: :desc).first
      membership  = ch.channel_memberships.find_by(user: current_user)
      unread      = membership&.last_read_at \
                    ? ch.messages.where("created_at > ?", membership.last_read_at)
                                 .where(message_thread_id: nil)
                                 .where(deleted_at: nil)
                                 .where("flag_action IS NULL OR flag_action != 'blocked'")
                                 .count \
                    : 0

      {
        id:               ch.id,
        name:             ch.name,
        channel_type:     ch.channel_type,
        sport:            ch.season.sport.name,
        season:           ch.season.name,
        season_id:        ch.season_id,
        school_id:        school.id,
        school_name:      school.name,
        system_generated: ch.system_generated,
        member_count:     ch.channel_memberships.count,
        last_message:     last_msg&.content,
        unread_count:     unread,
      }
    end
  end
end
