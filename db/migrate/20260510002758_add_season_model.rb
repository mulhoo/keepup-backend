class AddSeasonModel < ActiveRecord::Migration[8.0]
  def change
    # ── 1. seasons ────────────────────────────────────────────────────────────
    create_table :seasons do |t|
      t.references :sport,       null: false, foreign_key: true
      t.string     :name,        null: false
      t.string     :school_year, null: false
      t.date       :starts_at
      t.date       :ends_at
      t.integer    :status,      null: false, default: 0  # 0=active 1=archived 2=pending
      t.datetime   :archived_at
      t.references :archived_by, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :seasons, %i[sport_id school_year], unique: true

    # ── 2. season_memberships ─────────────────────────────────────────────────
    create_table :season_memberships do |t|
      t.references :user,       null: false, foreign_key: true
      t.references :season,     null: false, foreign_key: true
      t.integer    :role,       null: false
      t.boolean    :is_captain, null: false, default: false
      t.integer    :status,     null: false, default: 0  # 0=active 1=removed 2=archived
      t.datetime   :joined_at
      t.datetime   :removed_at
      t.timestamps
    end
    add_index :season_memberships, %i[user_id season_id], unique: true

    # ── 3. channels: sport_id → season_id ────────────────────────────────────
    add_reference :channels, :season, null: false, foreign_key: true
    remove_foreign_key :channels, :sports
    remove_column :channels, :sport_id, :bigint

    # ── 4. dm_conversations: sport_id → season_id ────────────────────────────
    remove_index  :dm_conversations, name: "index_dm_conversations_unique"
    add_reference :dm_conversations, :season, null: false, foreign_key: true
    add_index     :dm_conversations,
                  %i[participant_a_id participant_b_id season_id],
                  unique: true, name: "index_dm_conversations_unique"
    remove_foreign_key :dm_conversations, :sports
    remove_column :dm_conversations, :sport_id, :bigint

    # ── 5. drop sport_memberships (replaced by season_memberships) ────────────
    drop_table :sport_memberships

    # ── 6. drop the season string column from sports ──────────────────────────
    remove_column :sports, :season, :string
  end
end
