class CreateCalendarEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :calendar_events do |t|
      t.references :sport,      null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.string   :title,        null: false
      t.integer  :event_type,   null: false, default: 0
      t.integer  :home_away,    null: false, default: 0
      t.string   :location
      t.string   :opponent
      t.datetime :starts_at,    null: false
      t.datetime :ends_at
      t.text     :notes
      t.integer  :status,       null: false, default: 0
      t.timestamps
    end

    add_index :calendar_events, [ :sport_id, :starts_at ]
  end
end
