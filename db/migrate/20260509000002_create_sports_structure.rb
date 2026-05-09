class CreateSportsStructure < ActiveRecord::Migration[8.0]
  def change
    # A sport is a specific team program (e.g. "LWSD Varsity Girls Swimming 2025-26").
    # It is distinct from a generic sport type — it represents the actual team.
    # Sports can span multiple schools (co-op); status is pending until all ADs approve.
    create_table :sports do |t|
      t.string  :name, null: false          # "Varsity Girls Swimming"
      t.string  :sport_type                 # "swimming", "gymnastics", etc.
      t.string  :season                     # "2025-26"
      t.integer :status, default: 0, null: false  # pending, active, inactive
      t.timestamps
    end

    # One record per school participating in a sport.
    # All must reach `approved` before the sport goes active.
    # Any AD can revoke, which moves that record to `revoked`.
    create_table :coop_authorizations do |t|
      t.bigint  :sport_id, null: false
      t.bigint  :school_id, null: false
      t.bigint  :athletic_director_id       # user who approved/revoked
      t.integer :status, default: 0, null: false  # pending, approved, revoked
      t.datetime :approved_at
      t.datetime :revoked_at
      t.timestamps
    end

    add_index :coop_authorizations, [:sport_id, :school_id], unique: true
    add_index :coop_authorizations, :school_id
    add_index :coop_authorizations, :athletic_director_id

    # Roles: head_coach, assistant_coach, student, parent
    # school_id tracks which school this user belongs to within a co-op sport.
    create_table :sport_memberships do |t|
      t.bigint  :user_id, null: false
      t.bigint  :sport_id, null: false
      t.bigint  :school_id, null: false
      t.integer :role, null: false   # head_coach, assistant_coach, student, parent
      t.boolean :active, default: true, null: false
      t.date    :joined_date
      t.date    :left_date
      t.timestamps
    end

    add_index :sport_memberships, [:user_id, :sport_id], unique: true
    add_index :sport_memberships, :sport_id
    add_index :sport_memberships, :school_id
    add_index :sport_memberships, [:sport_id, :role]

    # Drives the hard interaction rules enforced at the API layer:
    #   parent <-> other students: BLOCKED
    #   student <-> other parents: BLOCKED
    create_table :parent_student_relationships do |t|
      t.bigint  :parent_id, null: false
      t.bigint  :student_id, null: false
      t.boolean :active, default: true, null: false
      t.timestamps
    end

    add_index :parent_student_relationships, [:parent_id, :student_id], unique: true
    add_index :parent_student_relationships, :student_id

    add_foreign_key :coop_authorizations, :sports
    add_foreign_key :coop_authorizations, :schools
    add_foreign_key :coop_authorizations, :users, column: :athletic_director_id
    add_foreign_key :sport_memberships, :users
    add_foreign_key :sport_memberships, :sports
    add_foreign_key :sport_memberships, :schools
    add_foreign_key :parent_student_relationships, :users, column: :parent_id
    add_foreign_key :parent_student_relationships, :users, column: :student_id
  end
end
