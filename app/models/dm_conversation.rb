class DmConversation < ApplicationRecord
  belongs_to :participant_a, class_name: "User"
  belongs_to :participant_b, class_name: "User"
  belongs_to :season

  has_many :direct_messages, dependent: :destroy

  validates :participant_a_id, uniqueness: { scope: [ :participant_b_id, :season_id ] }
  validate :participants_are_ordered
  validate :interaction_is_permitted

  # Always pass the lower ID as participant_a so the unique index works.
  def self.between(user_a, user_b, season)
    a, b = [ user_a, user_b ].sort_by(&:id)
    find_or_create_by!(participant_a: a, participant_b: b, season:)
  end

  def other_participant(user)
    user == participant_a ? participant_b : participant_a
  end

  def participant?(user)
    participant_a_id == user.id || participant_b_id == user.id
  end

  private

  def participants_are_ordered
    if participant_a_id.present? && participant_b_id.present?
      errors.add(:base, "participant_a must have the lower ID") if participant_a_id > participant_b_id
    end
  end

  # Enforces hard interaction rules at the model layer.
  # DB-level check would require a custom function; this guard runs on every create.
  def interaction_is_permitted
    return unless season && participant_a && participant_b

    role_a = participant_a.season_memberships.find_by(season:)&.role
    role_b = participant_b.season_memberships.find_by(season:)&.role

    blocked = blocked_combination?(role_a, role_b)
    errors.add(:base, "this combination of roles cannot exchange direct messages") if blocked
  end

  def blocked_combination?(role_a, role_b)
    pair = [ role_a, role_b ].sort
    # parent <-> other student: blocked
    # student <-> other parent: blocked
    pair == [ "parent", "student" ].sort
  end
end
