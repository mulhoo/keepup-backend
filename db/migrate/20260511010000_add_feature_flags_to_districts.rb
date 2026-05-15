class AddFeatureFlagsToDistricts < ActiveRecord::Migration[8.0]
  def change
    add_column :districts, :feature_flags, :jsonb, default: {}, null: false
    add_index  :districts, :feature_flags, using: :gin
  end
end
