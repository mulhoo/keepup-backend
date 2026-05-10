class AddAccessibilityToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :accessibility, :jsonb, default: {}, null: false
    add_index  :users, :accessibility, using: :gin
  end
end
