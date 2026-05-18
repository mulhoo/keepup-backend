class CreateCommissionerEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :commissioner_events do |t|
      t.references :sport_template, null: false, foreign_key: true
      t.references :district,       null: false, foreign_key: true
      t.string  :title,       null: false
      t.string  :event_type,  null: false, default: "meet"
      t.datetime :starts_at,  null: false
      t.datetime :ends_at
      t.string  :venue
      t.string  :status,      null: false, default: "scheduled"
      t.boolean :has_results, null: false, default: false
      t.string  :result_summary
      t.text    :notes,              default: ""
      t.text    :teams_json,         default: "[]"
      t.text    :matchup_pairs_json, default: "[]"
      t.timestamps
    end
  end
end
