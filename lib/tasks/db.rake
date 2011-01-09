namespace :geocms do

  task :load_config => :rails_env do
    require 'active_record'
    ActiveRecord::Base.configurations = Rails.configuration.database_configuration
    config = ActiveRecord::Base.configurations[Rails.env || 'development']
    @database = config['database']
    ENV['PGHOST'] = config["host"] if config["host"]
    ENV['PGPORT'] = config["port"].to_s if config["port"]
    ENV['PGPASSWORD'] = config["password"].to_s if config["password"]
  end

  desc "Pulls down the production database into the development database"
  task :pull do
    ActiveRecord::Base.configurations = Rails.configuration.database_configuration
    production_db = ActiveRecord::Base.configurations["production"]['database']
    database = ActiveRecord::Base.configurations[Rails.env]['database']
    system("sudo service postgresql-8.4 restart")
    system("dropdb #{database}")
    system("createdb #{database}")
    system("ssh okouam@xkcd.codeifier.com 'pg_dump #{production_db} -f #{production_db}.backup --clean --format c'")
    system("cd /tmp && scp okouam@xkcd.codeifier.com:/home/okouam/cms_production.backup cms_production.backup")
    system("cd /tmp && pg_restore #{production_db}.backup -d #{database} -v > pg_restore.log 2>&1")
    system("cd /tmp && rm cms_production.backup")
    system("ssh okouam@xkcd.codeifier.com 'rm #{production_db}.backup'")
  end

  namespace :features do

    desc "Import features required for rendering the 0-One digital map from shapefiles"
    task :import => [:environment] do
      folders = ["/home/okouam/Dropbox/0-One/Operations/Technical/Mapping/Shapefiles/Benin",
        "/home/okouam/Dropbox/0-One/Operations/Technical/Mapping/Shapefiles/Cote d'Ivoire",
        "/home/okouam/Dropbox/0-One/Operations/Technical/Mapping/Shapefiles/Togo",
        "/home/okouam/Dropbox/0-One/Operations/Technical/Mapping/Shapefiles/Senegal"]
      ActiveRecord::Base.connection.execute("TRUNCATE features")
      folders.each do |folder|
        puts "#{Feature.import(folder)} features were imported from the files in '#{folder}'"
      end
    end   
  end

  namespace :refresh do

    desc "Refresh all statistics"
    task :statistics => [:environment] do
      Statistics.new.refresh(:areas)
      Statistics.new.refresh(:categories)
      Statistics.new.refresh(:cache_counters)
      Statistics.new.refresh(:collectors)
    end

    desc "Refresh area statistics"
    task :areas => [:environment] do
      Statistics.new.refresh(:areas)
    end

    desc "Refresh category statistics"
    task :categories => [:environment] do
      Statistics.new.refresh(:categories)
    end

    desc "Refresh cache counters"
    task :cache_counters => [:environment] do
      Statistics.new.refresh(:cache_counters)
    end

    desc "Refresh counter statistics"
    task :counters => [:environment] do
      Statistics.new.refresh(:counters)
    end

  end

  desc "Load PostGIS functionality into a database"
  task :postgis do

    ActiveRecord::Base.configurations = Rails.configuration.database_configuration
    database = ActiveRecord::Base.configurations[Rails.env]['database']
    #`createlang plpgsql #{database}`

    postgis_sql_candidates = `locate postgis.sql`
    unless postgis_sql_candidates && !postgis_sql_candidates.blank?
      raise "The postgis.sql script cannot be found."
    end

    spatial_ref_sys_sql_candidates = `locate spatial_ref_sys.sql`
    unless spatial_ref_sys_sql_candidates && !spatial_ref_sys_sql_candidates.blank?
      raise "The spatial_ref_sys.sql script cannot be found."
    end

    postgis_sql = postgis_sql_candidates.split("\n")[0]
    spatial_ref_sys_sql = spatial_ref_sys_sql_candidates.split("\n")[0]

    `psql -d #{database} -f #{postgis_sql}`
    #`psql -d #{database} -f #{spatial_ref_sys_sql}`

  end

  desc "Kill all sessions to a database"
  task :disconnect =>  [:load_config, :environment] do
    processes = `ps ax|grep '.*[0-9]:[0-9][0-9] postgres:.*'|grep cms_development`
    if processes == ""
      puts "No connections to #{@database} found."
    else
      processes.each_line do |process|
        if process =~ /([0-9]+\s)/
          command = `sudo kill -9 #{$1.chop}`
          puts "Executing command: #{command}"
          `#{command}`
        end
      end
    end
  end

end
