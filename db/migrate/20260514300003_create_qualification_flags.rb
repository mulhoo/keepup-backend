class CreateQualificationFlags < ActiveRecord::Migration[8.0]
  def change
    create_table :qualification_flags do |t|
      t.references :meet_result, null: false, foreign_key: true
      t.string :athlete_name,   null: false
      t.string :school_abbr
      t.string :event_name,     null: false
      t.string :time_str
      t.string :level,          null: false
      t.string :standard_time
      t.string :status,         default: "pending", null: false
      t.timestamps
    end
  end
end
