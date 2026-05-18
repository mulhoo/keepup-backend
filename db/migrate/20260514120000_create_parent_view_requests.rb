class CreateParentViewRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :parent_view_requests do |t|
      t.references :parent,      null: false, foreign_key: { to_table: :users }
      t.references :child,       null: false, foreign_key: { to_table: :users }
      t.text       :reason,      null: false
      t.string     :status,      null: false, default: 'pending'
      t.references :reviewed_by, null: true,  foreign_key: { to_table: :users }
      t.datetime   :reviewed_at
      t.datetime   :expires_at

      t.timestamps
    end

    add_index :parent_view_requests, [ :parent_id, :child_id ]
    add_index :parent_view_requests, :status
  end
end
