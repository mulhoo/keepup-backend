class CreateChannelsAndMessages < ActiveRecord::Migration[8.0]
  def change
    # channel_type: broadcast (announcement, coach posts only) or conversation (open)
    create_table :channels do |t|
      t.bigint  :sport_id, null: false
      t.bigint  :created_by_id, null: false
      t.string  :name, null: false
      t.text    :description
      t.integer :channel_type, default: 0, null: false   # broadcast, conversation
      t.boolean :private, default: false, null: false
      t.boolean :student_created, default: false, null: false  # triggers head_coach notification
      t.boolean :active, default: true, null: false
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :channels, :sport_id
    add_index :channels, :created_by_id
    add_index :channels, :deleted_at

    create_table :channel_memberships do |t|
      t.bigint  :channel_id, null: false
      t.bigint  :user_id, null: false
      t.integer :role, default: 0, null: false   # member, admin
      t.datetime :last_read_at
      t.timestamps
    end

    add_index :channel_memberships, [ :channel_id, :user_id ], unique: true
    add_index :channel_memberships, :user_id

    # A thread lives inside a channel, anchored to a parent message.
    # Separated so we can track reply_count and last_reply_at without scanning messages.
    # Note: named message_threads to avoid conflict with Ruby's Thread class.
    create_table :message_threads do |t|
      t.bigint  :channel_id, null: false
      t.bigint  :parent_message_id, null: false
      t.integer :reply_count, default: 0, null: false
      t.datetime :last_reply_at
      t.timestamps
    end

    add_index :message_threads, :channel_id
    add_index :message_threads, :parent_message_id, unique: true

    create_table :messages do |t|
      t.bigint  :channel_id, null: false
      t.bigint  :message_thread_id            # null = top-level channel message
      t.bigint  :sender_id, null: false

      t.text    :content, null: false

      # Gemma 4 on-device moderation result (flag set by mobile client before send)
      t.boolean :flagged, default: false, null: false
      t.decimal :moderation_score, precision: 4, scale: 3
      t.text    :flag_reason
      t.boolean :flag_reviewed, default: false, null: false
      t.bigint  :flag_reviewed_by_id
      t.datetime :flag_reviewed_at
      t.string :flag_action                  # dismissed, removed, escalated

      # Soft delete — data is never hard-deleted
      t.datetime :deleted_at
      t.bigint :deleted_by_id

      t.timestamps
    end

    add_index :messages, :channel_id
    add_index :messages, :message_thread_id
    add_index :messages, :sender_id
    add_index :messages, :flagged
    add_index :messages, :deleted_at
    add_index :messages, [ :channel_id, :created_at ]

    create_table :reactions do |t|
      t.bigint :message_id, null: false
      t.bigint :user_id, null: false
      t.string :emoji, null: false
      t.timestamps
    end

    add_index :reactions, [ :message_id, :user_id, :emoji ], unique: true
    add_index :reactions, :user_id

    add_foreign_key :channels, :sports
    add_foreign_key :channels, :users, column: :created_by_id
    add_foreign_key :channel_memberships, :channels
    add_foreign_key :channel_memberships, :users
    add_foreign_key :message_threads, :channels
    add_foreign_key :messages, :channels
    add_foreign_key :messages, :message_threads
    add_foreign_key :messages, :users, column: :sender_id
    add_foreign_key :messages, :users, column: :flag_reviewed_by_id
    add_foreign_key :messages, :users, column: :deleted_by_id
    add_foreign_key :reactions, :messages
    add_foreign_key :reactions, :users
  end
end
