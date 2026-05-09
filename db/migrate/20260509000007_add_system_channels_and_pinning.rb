class AddSystemChannelsAndPinning < ActiveRecord::Migration[8.0]
  def change
    # Marks auto-created default channels (general, announcements, athletes-only).
    # System-generated channels cannot be deleted or renamed by users.
    add_column :channels, :system_generated, :boolean, default: false, null: false

    # channel_type enum gains two new values at the model level:
    #   0 = broadcast      (coaches post; others read-only, except captains)
    #   1 = conversation   (open to all members)
    #   2 = athletes_only  (students only; captains can add/remove members)
    #   3 = coaches_only   (coaches only)
    # Integer column — no DB migration needed for adding enum values.

    add_column :messages, :pinned_at, :datetime
    add_column :messages, :pinned_by_id, :bigint
    add_index  :messages, :pinned_at

    add_foreign_key :messages, :users, column: :pinned_by_id
  end
end
