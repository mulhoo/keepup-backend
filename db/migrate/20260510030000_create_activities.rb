class CreateActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :activities do |t|
      t.integer    :event_type,   null: false
      t.references :actor,        foreign_key: { to_table: :users }, null: true
      t.references :subject,      polymorphic: true, null: true
      t.references :season,       foreign_key: true, null: true
      t.references :school,       foreign_key: true, null: true
      t.jsonb      :metadata,     null: false, default: {}
      t.datetime   :occurred_at,  null: false

      t.timestamps
    end

    add_index :activities, [ :school_id, :occurred_at ]
    add_index :activities, [ :season_id, :occurred_at ]
    add_index :activities, :event_type
  end
end
