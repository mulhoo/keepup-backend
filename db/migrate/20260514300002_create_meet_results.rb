class CreateMeetResults < ActiveRecord::Migration[8.0]
  def change
    create_table :meet_results do |t|
      t.references :sport,       null: false, foreign_key: true
      t.references :home_school, null: false, foreign_key: { to_table: :schools }
      t.references :away_school, null: true,  foreign_key: { to_table: :schools }
      t.string  :away_school_name
      t.date    :date,           null: false
      t.string  :venue
      t.boolean :cross_division, default: false, null: false
      t.integer :home_score,     default: 0,     null: false
      t.integer :away_score,     default: 0,     null: false
      t.text    :ai_summary
      t.text    :ai_standouts_json, default: "[]", null: false
      t.text    :ai_focus
      t.references :uploaded_by, foreign_key: { to_table: :users }, null: true
      t.string  :status,         default: "pending_opponent", null: false
      t.text    :events_json,    default: "[]",  null: false
      t.timestamps
    end
  end
end
