class AddReplyToDirectMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :direct_messages, :reply_to_id, :bigint
    add_index  :direct_messages, :reply_to_id
    add_foreign_key :direct_messages, :direct_messages, column: :reply_to_id
  end
end
