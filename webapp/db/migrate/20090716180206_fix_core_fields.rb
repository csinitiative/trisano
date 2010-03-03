class FixCoreFields < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      ruby "#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/script/core_fields_updater.rb"
    end
  end

  def self.down
  end
end
