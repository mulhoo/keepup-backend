class CreateInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :invitations do |t|
      t.string     :token,       null: false
      t.string     :email,       null: false
      t.string     :first_name
      t.string     :last_name
      t.string     :role,        null: false
      t.boolean    :is_captain,  null: false, default: false
      t.references :season,      null: false, foreign_key: true
      t.references :invited_by,  null: false, foreign_key: { to_table: :users }
      t.datetime   :expires_at,  null: false
      t.datetime   :accepted_at
      t.timestamps
    end

    add_index :invitations, :token, unique: true
    add_index :invitations, [ :season_id, :email ], unique: true
  end
end
