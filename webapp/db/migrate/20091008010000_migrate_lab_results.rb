class MigrateLabResults < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      ruby "#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/script/migrate_lab_results.rb"
    end
  end

  def self.down
  end
end
