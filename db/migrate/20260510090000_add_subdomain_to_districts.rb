class AddSubdomainToDistricts < ActiveRecord::Migration[8.0]
  def change
    add_column :districts, :subdomain, :string
    add_index  :districts, :subdomain, unique: true
  end
end
