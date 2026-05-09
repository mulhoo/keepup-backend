class CreateMessageFlags < ActiveRecord::Migration[8.0]
  def change
    # Quiet human-initiated flag for channel messages, separate from Gemma's automated
    # moderation pipeline (messages.flagged). Escalation chain: captain -> head_coach -> AD.
    create_table :message_flags do |t|
      t.bigint  :message_id, null: false
      t.bigint  :flagged_by_id, null: false   # captain who raised the flag
      t.text    :reason

      # pending: awaiting head coach review
      # reviewed: head coach has seen it
      # escalated: head coach forwarded to AD
      # resolved: closed by head coach or AD
      t.integer :status, default: 0, null: false

      t.bigint  :reviewed_by_id               # head coach
      t.datetime :reviewed_at
      t.bigint  :escalated_to_id              # AD
      t.datetime :escalated_at
      t.bigint  :resolved_by_id
      t.datetime :resolved_at

      t.timestamps
    end

    add_index :message_flags, :message_id
    add_index :message_flags, :flagged_by_id
    add_index :message_flags, :status
    add_index :message_flags, [:message_id, :flagged_by_id], unique: true

    add_foreign_key :message_flags, :messages
    add_foreign_key :message_flags, :users, column: :flagged_by_id
    add_foreign_key :message_flags, :users, column: :reviewed_by_id
    add_foreign_key :message_flags, :users, column: :escalated_to_id
    add_foreign_key :message_flags, :users, column: :resolved_by_id
  end
end
