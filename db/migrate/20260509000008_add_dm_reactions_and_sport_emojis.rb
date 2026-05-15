class AddDmReactionsAndSportEmojis < ActiveRecord::Migration[8.0]
  def change
    # Sport-specific custom emojis (e.g. a swimmer emoji for a swim team).
    # Students request; head coaches or captains approve.
    # The `name` field (e.g. ":swimmer:") is used as the emoji identifier in reactions.
    create_table :sport_emojis do |t|
      t.bigint  :sport_id, null: false
      t.bigint  :requested_by_id, null: false
      t.string  :name, null: false        # :swimmer: — unique per sport
      t.string  :image_url, null: false
      t.integer :status, default: 0, null: false  # pending, approved, rejected
      t.bigint  :reviewed_by_id           # head coach or captain who approved/rejected
      t.datetime :reviewed_at
      t.timestamps
    end

    add_index :sport_emojis, [ :sport_id, :name ], unique: true
    add_index :sport_emojis, :sport_id
    add_index :sport_emojis, :status
    add_foreign_key :sport_emojis, :sports
    add_foreign_key :sport_emojis, :users, column: :requested_by_id
    add_foreign_key :sport_emojis, :users, column: :reviewed_by_id

    # Extend reactions to support DMs and custom sport emojis.
    # message_id becomes nullable — exactly one of message_id / direct_message_id must be set
    # (enforced at the application layer).
    # emoji stores either a unicode character or a :name: string for custom emojis.
    # sport_emoji_id is set only for custom emojis (provides the image_url for rendering).
    change_column_null :reactions, :message_id, true
    add_column :reactions, :direct_message_id, :bigint
    add_column :reactions, :sport_emoji_id, :bigint

    # Replace the old non-partial unique index with partial indexes per target type.
    remove_index :reactions, [ :message_id, :user_id, :emoji ]

    add_index :reactions, [ :message_id, :user_id, :emoji ],
              unique: true,
              where: "message_id IS NOT NULL",
              name: "index_reactions_on_message_id_user_id_emoji"

    add_index :reactions, [ :direct_message_id, :user_id, :emoji ],
              unique: true,
              where: "direct_message_id IS NOT NULL",
              name: "index_reactions_on_dm_id_user_id_emoji"

    add_index :reactions, :direct_message_id
    add_index :reactions, :sport_emoji_id

    add_foreign_key :reactions, :direct_messages
    add_foreign_key :reactions, :sport_emojis
  end
end
