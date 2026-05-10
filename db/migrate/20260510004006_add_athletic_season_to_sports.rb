class AddAthleticSeasonToSports < ActiveRecord::Migration[8.0]
  def change
    # 0=fall 1=winter 2=spring 3=year_round
    add_column :sports, :athletic_season, :integer, null: false, default: 0
    add_index  :sports, :athletic_season
  end
end
