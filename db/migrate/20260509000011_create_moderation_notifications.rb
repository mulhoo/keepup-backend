class CreateModerationNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :moderation_notifications do |t|
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.references :message, null: true, foreign_key: true
      t.references :direct_message, null: true, foreign_key: true
      t.integer :notification_type, null: false
      t.integer :recipient_role, null: false
      t.datetime :read_at
      t.timestamps
    end

    add_index :moderation_notifications, [ :recipient_id, :read_at ],
              name: "index_mod_notifications_on_recipient_and_read"
    add_index :moderation_notifications, :notification_type
  end
end
