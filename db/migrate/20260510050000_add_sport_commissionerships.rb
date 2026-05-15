class AddSportCommissionerships < ActiveRecord::Migration[8.0]
  def change
    create_table :sport_commissionerships do |t|
      t.references :user,           null: false, foreign_key: true
      t.references :sport_template, null: false, foreign_key: true
      t.references :district,       null: false, foreign_key: true
      t.references :assigned_by,    foreign_key: { to_table: :users }
      t.integer    :status, null: false, default: 0
      t.datetime   :assigned_at

      t.timestamps
    end

    add_index :sport_commissionerships,
              [ :user_id, :sport_template_id, :district_id ],
              unique: true,
              name: "index_sport_commissionerships_unique"
  end
end
