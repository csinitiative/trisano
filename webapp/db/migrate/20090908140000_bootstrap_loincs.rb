class BootstrapLoincs < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      ruby "#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/script/load_loinc_codes.rb #{RAILS_ROOT}/db/defaults/loinc_codes_to_common_test_types.csv"
    end
  end

  def self.down
  end
end
