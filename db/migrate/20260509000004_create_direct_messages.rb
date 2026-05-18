class CreateDirectMessages < ActiveRecord::Migration[8.0]
  def change
    # Conversation between exactly two users, scoped to a sport (sports are siloed).
    # participant_a_id is always the lower user ID to enforce the uniqueness constraint
    # without needing two rows per pair.
    create_table :dm_conversations do |t|
      t.bigint  :participant_a_id, null: false   # lower user id
      t.bigint  :participant_b_id, null: false   # higher user id
      t.bigint  :sport_id, null: false           # DMs scoped to sport context
      t.datetime :last_message_at
      t.timestamps
    end

    add_index :dm_conversations,
              [ :participant_a_id, :participant_b_id, :sport_id ],
              unique: true,
              name: "index_dm_conversations_unique"
    add_index :dm_conversations, :participant_b_id
    add_index :dm_conversations, :sport_id

    create_table :direct_messages do |t|
      t.bigint  :dm_conversation_id, null: false
      t.bigint  :sender_id, null: false
      t.text    :content, null: false
      t.datetime :read_at

      # Gemma 4 on-device moderation result
      t.boolean :flagged, default: false, null: false
      t.decimal :moderation_score, precision: 4, scale: 3
      t.text    :flag_reason
      t.boolean :flag_reviewed, default: false, null: false
      t.bigint  :flag_reviewed_by_id
      t.datetime :flag_reviewed_at
      t.string :flag_action   # dismissed, removed, escalated

      # Soft delete only — data persists for audit trail
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :direct_messages, :dm_conversation_id
    add_index :direct_messages, :sender_id
    add_index :direct_messages, :flagged
    add_index :direct_messages, :deleted_at
    add_index :direct_messages, [ :dm_conversation_id, :created_at ]

    add_foreign_key :dm_conversations, :users, column: :participant_a_id
    add_foreign_key :dm_conversations, :users, column: :participant_b_id
    add_foreign_key :dm_conversations, :sports
    add_foreign_key :direct_messages, :dm_conversations
    add_foreign_key :direct_messages, :users, column: :sender_id
    add_foreign_key :direct_messages, :users, column: :flag_reviewed_by_id
  end
end
