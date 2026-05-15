class CreateMessageChallenges < ActiveRecord::Migration[8.0]
  def change
    create_table :message_challenges do |t|
      t.references :message,     null: false, foreign_key: true
      t.references :challenger,  null: false, foreign_key: { to_table: :users }
      t.text       :reason
      t.string     :status,      null: false, default: 'pending'
      t.references :reviewed_by, null: true,  foreign_key: { to_table: :users }
      t.datetime   :reviewed_at

      t.timestamps
    end

    add_index :message_challenges, [ :message_id, :status ]
  end
end
