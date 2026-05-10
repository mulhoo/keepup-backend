namespace :db do
  desc "Drop, recreate, migrate, and seed the database from scratch (prompts for confirmation)"
  task reseed: :environment do
    print "This will DESTROY all data in '#{ActiveRecord::Base.connection_db_config.database}' and reseed from scratch. Continue? [y/N] "
    $stdout.flush
    input = $stdin.gets.to_s.strip.downcase

    unless input == "y"
      puts "Aborted."
      exit 1
    end

    puts "\nDropping database..."
    Rake::Task["db:drop"].invoke

    puts "Creating database..."
    Rake::Task["db:create"].invoke

    puts "Running migrations..."
    Rake::Task["db:migrate"].invoke

    puts "Seeding..."
    Rake::Task["db:seed"].invoke

    puts "\nDone."
  end
end
