class AddThemeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :theme, null: true, foreign_key: true
  end
end
