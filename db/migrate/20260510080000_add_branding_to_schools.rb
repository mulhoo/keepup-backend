class AddBrandingToSchools < ActiveRecord::Migration[8.0]
  def change
    add_column :schools, :icon_url,   :string
    add_column :schools, :banner_url, :string
  end
end
