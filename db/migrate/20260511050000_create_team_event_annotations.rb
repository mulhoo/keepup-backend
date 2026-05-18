class CreateTeamEventAnnotations < ActiveRecord::Migration[8.0]
  def change
    create_table :team_event_annotations do |t|
      t.references :calendar_event, null: false, foreign_key: true
      t.references :season,         null: false, foreign_key: true
      t.references :updated_by,     null: false, foreign_key: { to_table: :users }
      t.datetime :warmup_time
      t.text     :team_notes
      t.timestamps
    end

    add_index :team_event_annotations, [ :calendar_event_id, :season_id ],
              unique: true, name: "index_annotations_on_event_and_season"
  end
end
