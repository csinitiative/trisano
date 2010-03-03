class BootstrapTestTypes < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      ruby "#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/script/load_common_test_types.rb #{RAILS_ROOT}/db/defaults/common_test_types.csv"
    end
  end

  def self.down
  end
end
