class AddStartDateToInstitutionRoles < ActiveRecord::Migration[8.0]
  def up
    add_column :institution_roles, :start_date, :date
    InstitutionRole.update_all(start_date: Date.current)
    change_column_null :institution_roles, :start_date, false
  end

  def down
    remove_column :institution_roles, :start_date
  end
end
