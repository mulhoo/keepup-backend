class ResetDemoDatabaseJob < ApplicationJob
  queue_as :background

  SKIP_TABLES = %w[schema_migrations ar_internal_metadata].freeze

  def perform
    Rails.logger.info("[ResetDemoDatabaseJob] Starting demo database reset")

    conn = ActiveRecord::Base.connection

    tables = conn.tables.reject { |t| SKIP_TABLES.include?(t) }
    quoted = tables.map { |t| conn.quote_table_name(t) }.join(", ")

    conn.disable_referential_integrity do
      conn.execute("TRUNCATE #{quoted} RESTART IDENTITY CASCADE")
    end

    load Rails.root.join("db/seeds.rb")

    Rails.logger.info("[ResetDemoDatabaseJob] Demo database reset complete at #{Time.current}")
  end
end
