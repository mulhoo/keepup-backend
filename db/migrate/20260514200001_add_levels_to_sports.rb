class AddLevelsToSports < ActiveRecord::Migration[8.0]
  def change
    add_column :sports, :levels, :string, array: true, default: []
  end
end
