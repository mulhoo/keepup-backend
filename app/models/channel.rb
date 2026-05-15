class Channel < ApplicationRecord
  belongs_to :season
  belongs_to :created_by, class_name: "User"

  has_many :channel_memberships, dependent: :destroy
  has_many :users, through: :channel_memberships
  has_many :messages, dependent: :destroy
  has_many :message_threads, dependent: :destroy

  enum :channel_type, { conversation: 0, broadcast: 1, athletes_only: 2, coaches_only: 3, family_group: 4 }

  validates :name, :channel_type, presence: true
  validates :season, :created_by, presence: true

  scope :active, -> { where(active: true, deleted_at: nil) }
  scope :system_generated, -> { where(system_generated: true) }
  scope :visible_to, ->(user) { joins(:channel_memberships).where(channel_memberships: { user: }) }

  after_create :notify_head_coaches_if_student_created, if: :student_created?

  def soft_delete!(deleted_by)
    update!(deleted_at: Time.current, active: false)
  end

  def broadcast?
    channel_type == "broadcast"
  end

  def viewable_by?(user)
    membership = user.season_memberships.active.find_by(season:)
    return false unless membership

    case channel_type
    when "coaches_only"        then membership.role.in?(%w[head_coach assistant_coach])
    when "athletes_only"       then membership.role.in?(%w[student head_coach assistant_coach])
    when "family_group"        then channel_memberships.exists?(user_id: user.id)
    when "conversation",
         "broadcast"           then true
    else false
    end
  end

  private

  def notify_head_coaches_if_student_created
    # TODO: enqueue StudentChannelCreatedNotificationJob
  end
end
