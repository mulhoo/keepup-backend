class CreateTimeStandards < ActiveRecord::Migration[8.0]
  def change
    create_table :time_standards do |t|
      t.references :sport_template, null: false, foreign_key: true
      t.string :gender,             default: "girls", null: false
      t.string :event_name,         null: false
      t.string :kingco
      t.string :districts_wildcard
      t.string :districts
      t.string :state
      t.timestamps
    end
    add_index :time_standards, [ :sport_template_id, :gender, :event_name ], unique: true,
              name: "idx_time_standards_unique"
  end
end
