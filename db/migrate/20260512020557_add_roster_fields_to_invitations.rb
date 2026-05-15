class AddRosterFieldsToInvitations < ActiveRecord::Migration[8.0]
  def change
    add_column :invitations, :dob, :date
    add_column :invitations, :jersey_number, :string
    add_column :invitations, :grade, :string
    add_column :invitations, :level, :string
    add_column :invitations, :position, :string
  end
end
