class AddRosterFieldsToUsersAndSeasonMemberships < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :dob, :date

    add_column :season_memberships, :jersey_number, :string
    add_column :season_memberships, :grade,         :string
    add_column :season_memberships, :level,         :string
    add_column :season_memberships, :position,      :string
  end
end
