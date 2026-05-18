class AddScheduledAtToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :scheduled_at, :datetime
    add_index :messages, :scheduled_at
  end
end
