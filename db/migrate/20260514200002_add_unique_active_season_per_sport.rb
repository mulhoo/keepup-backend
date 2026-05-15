class AddUniqueActiveSeasonPerSport < ActiveRecord::Migration[8.0]
  def up
    # Enforce at most one active season per sport. Uses a partial index so that
    # archived and pending seasons are unconstrained (a sport can have many past seasons).
    # status = 0 maps to Season.statuses[:active]
    execute <<~SQL
      CREATE UNIQUE INDEX index_seasons_on_sport_id_when_active
      ON seasons (sport_id)
      WHERE status = 0
    SQL
  end

  def down
    execute "DROP INDEX IF EXISTS index_seasons_on_sport_id_when_active"
  end
end
