class CreateAuditTrail < ActiveRecord::Migration[8.0]
  def change
    # Every time a privileged user accesses another user's data, a record is created.
    # The notification chain:
    #   coach accesses -> AD notified
    #   AD accesses    -> school_admin notified
    #   school_admin   -> district_admin notified
    #   district_admin -> dpa_contact notified
    #
    # Gemma 4 (web) runs behavioral anomaly detection across these records,
    # flagging patterns like repeated access to one student's data in a short window.
    create_table :access_logs do |t|
      t.bigint  :accessor_id, null: false         # who accessed
      t.bigint  :accessed_user_id, null: false    # whose data was accessed
      t.string  :accessor_role, null: false       # role at time of access
      t.integer :reason, null: false              # conduct_concern, safety_issue, parent_request
      t.string  :resource_type                    # Message, DirectMessage, Channel, etc.
      t.bigint  :resource_id
      t.bigint  :sport_id                         # sport context for scoping

      # Gemma 4 behavioral anomaly detection result
      t.boolean :anomaly_flagged, default: false, null: false
      t.decimal :anomaly_score, precision: 4, scale: 3
      t.text    :anomaly_reason
      t.boolean :anomaly_reviewed, default: false, null: false

      t.timestamps
    end

    add_index :access_logs, :accessor_id
    add_index :access_logs, :accessed_user_id
    add_index :access_logs, [ :resource_type, :resource_id ]
    add_index :access_logs, :anomaly_flagged
    add_index :access_logs, [ :accessor_id, :created_at ]           # time-window queries
    add_index :access_logs, [ :accessed_user_id, :created_at ]      # pattern detection

    # One notification per access log, sent to the supervisor immediately above
    # the accessor in the hierarchy.
    create_table :access_notifications do |t|
      t.bigint  :notified_user_id, null: false
      t.bigint  :access_log_id, null: false
      t.datetime :read_at
      t.timestamps
    end

    add_index :access_notifications, :notified_user_id
    add_index :access_notifications, :access_log_id
    add_index :access_notifications, [ :notified_user_id, :read_at ]

    add_foreign_key :access_logs, :users, column: :accessor_id
    add_foreign_key :access_logs, :users, column: :accessed_user_id
    add_foreign_key :access_logs, :sports
    add_foreign_key :access_notifications, :users, column: :notified_user_id
    add_foreign_key :access_notifications, :access_logs
  end
end
