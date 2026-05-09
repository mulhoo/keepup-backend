class CreateDeviceTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :device_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false
      t.string :platform, null: false, default: "ios"
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :device_tokens, :token, unique: true
    add_index :device_tokens, [:user_id, :active]
  end
end
