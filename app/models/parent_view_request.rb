class ParentViewRequest < ApplicationRecord
  belongs_to :parent,      class_name: "User"
  belongs_to :child,       class_name: "User"
  belongs_to :reviewed_by, class_name: "User", optional: true

  enum :status, { pending: "pending", approved: "approved", denied: "denied" }

  scope :active_approval_for, ->(parent, child) {
    approved
      .where(parent: parent, child: child)
      .where("expires_at > ?", Time.current)
  }

  def approve!(reviewer)
    update!(
      status:      :approved,
      reviewed_by: reviewer,
      reviewed_at: Time.current,
      expires_at:  48.hours.from_now,
    )
  end

  def deny!(reviewer)
    update!(
      status:      :denied,
      reviewed_by: reviewer,
      reviewed_at: Time.current,
    )
  end
end
