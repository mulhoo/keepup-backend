class AddEmailDomainToDistricts < ActiveRecord::Migration[8.0]
  def change
    add_column :districts, :email_domain, :string
  end
end
