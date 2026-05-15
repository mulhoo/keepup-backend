class AddMicrosoftUidToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :microsoft_uid, :string
    add_index  :users, :microsoft_uid, unique: true
  end
end
