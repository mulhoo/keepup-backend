class AddHomeSchoolAndCaptainToSports < ActiveRecord::Migration[8.0]
  def change
    # Every sport has a home school — the school that owns/created the team.
    # Co-op partner schools are tracked separately in coop_authorizations.
    add_column :sports, :school_id, :bigint, null: false
    add_index  :sports, :school_id
    add_foreign_key :sports, :schools

    # Only meaningful when sport_memberships.role = student.
    # Head coaches set this; aligns with FinalForms' captain designation for future integration.
    add_column :sport_memberships, :is_captain, :boolean, default: false, null: false
  end
end
