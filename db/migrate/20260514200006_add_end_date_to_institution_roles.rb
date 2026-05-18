class AddEndDateToInstitutionRoles < ActiveRecord::Migration[8.0]
  def change
    add_column :institution_roles, :end_date, :date
  end
end
