class ArchivePriorYearSeasons < ActiveRecord::Migration[8.0]
  def up
    year         = Date.current.month >= 8 ? Date.current.year : Date.current.year - 1
    current_year = "#{year}-#{(year + 1).to_s[-2..]}"

    stale_season_ids = Season.where(status: 0).where.not(school_year: current_year).pluck(:id)
    return if stale_season_ids.empty?

    Season.where(id: stale_season_ids).update_all(status: 1, archived_at: Time.current)
    SeasonMembership.where(season_id: stale_season_ids, status: 0).update_all(status: 2)
    Channel.where(season_id: stale_season_ids).update_all(active: false)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
