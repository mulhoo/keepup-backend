class DropTeamLevelsAndFixSeasonKey < ActiveRecord::Migration[8.0]
  def up
    remove_foreign_key :seasons, column: :team_level_id if foreign_key_exists?(:seasons, column: :team_level_id)
    remove_index  :seasons, name: "index_seasons_on_team_level_id_and_school_year", if_exists: true
    remove_index  :seasons, name: "index_seasons_on_team_level_id",                 if_exists: true
    remove_column :seasons, :team_level_id, :bigint

    # Merge duplicate (sport_id, school_year) seasons that existed when Varsity/JV
    # were modeled as separate seasons. For each duplicate group:
    #   - keep the lowest-id season
    #   - move non-conflicting child rows to the keeper
    #   - delete conflicting child rows (they already exist on the keeper)
    #   - delete the now-empty duplicate season
    duplicates = execute(<<~SQL).to_a
      SELECT sport_id, school_year, array_agg(id ORDER BY id) AS ids
      FROM seasons
      GROUP BY sport_id, school_year
      HAVING count(*) > 1
    SQL

    duplicates.each do |row|
      ids         = row["ids"].tr('{}', '').split(',').map(&:to_i)
      keeper_id   = ids.first
      discard_ids = ids.drop(1)

      discard_ids.each do |dup_id|
        # season_memberships: unique on (user_id, season_id)
        # drop the dup's memberships for users already on the keeper, then move the rest
        if table_exists?(:season_memberships)
          execute <<~SQL
            DELETE FROM season_memberships
            WHERE season_id = #{dup_id}
              AND user_id IN (SELECT user_id FROM season_memberships WHERE season_id = #{keeper_id})
          SQL
          execute "UPDATE season_memberships SET season_id = #{keeper_id} WHERE season_id = #{dup_id}"
        end

        # channels: may have a unique constraint on (season_id, name)
        # drop the dup's channels that already exist on the keeper, then move the rest
        if table_exists?(:channels)
          execute <<~SQL
            DELETE FROM channels
            WHERE season_id = #{dup_id}
              AND name IN (SELECT name FROM channels WHERE season_id = #{keeper_id})
          SQL
          execute "UPDATE channels SET season_id = #{keeper_id} WHERE season_id = #{dup_id}"
        end

        # calendar_events: no unique constraint, safe to move all
        if table_exists?(:calendar_events)
          execute "UPDATE calendar_events SET season_id = #{keeper_id} WHERE season_id = #{dup_id}"
        end

        execute "DELETE FROM seasons WHERE id = #{dup_id}"
      end
    end

    # One season per sport per school year
    add_index :seasons, [ :sport_id, :school_year ], unique: true,
              name: "index_seasons_on_sport_id_and_school_year"

    drop_table :team_levels
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
