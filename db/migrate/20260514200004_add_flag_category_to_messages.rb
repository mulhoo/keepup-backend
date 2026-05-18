class AddFlagCategoryToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages,        :flag_category, :string
    add_column :direct_messages, :flag_category, :string
  end
end
