class ChannelMembership < ApplicationRecord
  belongs_to :channel
  belongs_to :user

  enum :role, { member: 0, admin: 1 }

  validates :channel_id, uniqueness: { scope: :user_id }
end
