class AddBroadcastIdToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :broadcast_id, :string
    add_index  :messages, :broadcast_id
  end
end
