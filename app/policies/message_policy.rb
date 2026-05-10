class MessagePolicy < ApplicationPolicy
  def index?     = channel_viewable?
  def create?    = channel_viewable?
  def translate? = channel_viewable?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(channel: policy_scope_channels)
    end

    private

    def policy_scope_channels
      ChannelPolicy::Scope.new(user, Channel).resolve
    end
  end

  private

  def channel_viewable?
    channel = record.is_a?(Channel) ? record : record.channel
    ChannelPolicy.new(user, channel).show?
  end
end
