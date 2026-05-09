class CreateUsersAndInstitutionalHierarchy < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :password_digest
      t.string :profile_photo_url

      # Invite-only onboarding
      t.string  :invitation_token
      t.datetime :invitation_sent_at
      t.datetime :invitation_accepted_at
      t.bigint  :invited_by_id

      # OAuth
      t.string  :oauth_provider
      t.string  :oauth_uid
      t.text    :oauth_token
      t.text    :oauth_refresh_token
      t.datetime :oauth_expires_at

      # JWT refresh token revocation
      t.string  :jti  # unique token identifier, nulled on logout

      t.boolean :active, default: true, null: false
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :invitation_token, unique: true
    add_index :users, :jti, unique: true
    add_index :users, :deleted_at

    create_table :districts do |t|
      t.string :name, null: false
      t.string :city, null: false
      t.string :state, null: false
      t.string :country, default: "US", null: false
      t.boolean :active, default: true, null: false
      t.timestamps
    end

    add_index :districts, :name, unique: true

    create_table :schools do |t|
      t.bigint :district_id, null: false
      t.string :name, null: false
      t.string :city
      t.string :state
      t.boolean :active, default: true, null: false
      t.timestamps
    end

    add_index :schools, :district_id
    add_index :schools, [:district_id, :name], unique: true

    # Roles scoped to an institution (district or school).
    # district_admin / dpa_contact -> district_id set, school_id null
    # school_admin / athletic_director -> school_id set, district_id null
    create_table :institution_roles do |t|
      t.bigint  :user_id, null: false
      t.integer :role, null: false   # enum: district_admin, school_admin, athletic_director, dpa_contact
      t.bigint  :district_id
      t.bigint  :school_id
      t.boolean :active, default: true, null: false
      t.timestamps
    end

    add_index :institution_roles, :user_id
    add_index :institution_roles, :district_id
    add_index :institution_roles, :school_id
    add_index :institution_roles,
              [:user_id, :role, :district_id, :school_id],
              unique: true,
              name: "index_institution_roles_unique"

    add_foreign_key :schools, :districts
    add_foreign_key :institution_roles, :users
    add_foreign_key :institution_roles, :districts
    add_foreign_key :institution_roles, :schools
  end
end
