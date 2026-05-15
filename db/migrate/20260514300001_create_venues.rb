class CreateVenues < ActiveRecord::Migration[8.0]
  def change
    create_table :venues do |t|
      t.references :school, foreign_key: true
      t.string  :name,               null: false
      t.string  :facility_type,      null: false, default: "other"
      t.string  :address,            null: false, default: ""
      t.text    :availability_json,  default: "[]"
      t.boolean :temporarily_closed, null: false, default: false
      t.string  :closed_reason,      default: ""
      t.timestamps
    end
  end
end
