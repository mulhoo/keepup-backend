class DropCalendarTables < ActiveRecord::Migration[8.0]
  def up
    drop_table :team_event_annotations
    drop_table :calendar_events
  end

  def down
    create_table :calendar_events do |t|
      t.references :sport,      null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.string   :title,      null: false
      t.integer  :event_type, default: 0, null: false
      t.integer  :home_away,  default: 0, null: false
      t.string   :location
      t.string   :opponent
      t.datetime :starts_at,  null: false
      t.datetime :ends_at
      t.text     :notes
      t.integer  :status,     default: 0, null: false
      t.timestamps
    end
    add_index :calendar_events, [ :sport_id, :starts_at ]

    create_table :team_event_annotations do |t|
      t.references :calendar_event, null: false, foreign_key: true
      t.references :season,         null: false, foreign_key: true
      t.references :updated_by,     null: false, foreign_key: { to_table: :users }
      t.datetime :warmup_time
      t.text     :team_notes
      t.timestamps
    end
    add_index :team_event_annotations, [ :calendar_event_id, :season_id ], unique: true
  end
end
