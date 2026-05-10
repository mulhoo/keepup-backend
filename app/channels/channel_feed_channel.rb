class ChannelFeedChannel < ApplicationCable::Channel
  def subscribed
    channel = Channel.find_by(id: params[:channel_id])

    unless channel && authorized_for_channel?(channel)
      return reject
    end

    stream_from "channel_feed:#{channel.id}"
  end

  def unsubscribed
  end

  private

  def authorized_for_channel?(channel)
    current_user.season_memberships
                .active
                .exists?(season: channel.season) &&
      channel.viewable_by?(current_user)
  end
end
