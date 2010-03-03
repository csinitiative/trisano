class ChangeInStateCode < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      execute("UPDATE external_codes SET the_code = 'AIS' where code_name = 'imported' and the_code = 'UT'")
      execute("UPDATE export_conversion_values SET value_from = 'AIS' where export_column_ID = (SELECT id FROM export_columns WHERE export_column_name ='IMPORTED') and value_from = 'UT'")
    end
  end

  def self.down
  end
end
