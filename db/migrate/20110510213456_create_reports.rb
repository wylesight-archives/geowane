class CreateReports < ActiveRecord::Migration
  def self.up

    execute("CREATE SCHEMA reports AUTHORIZATION deployment")

    files = ["partners", "categories", "cities", "collectors"]
    files.each do |file|
      script = File.join(Rails.root, "db/resources/scripts/reports/#{file}.sql")
      execute File.read(script)
    end
  end

  def self.down
  end
end
