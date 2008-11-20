class ProductionLoadDiseaseExportData < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      say "Clean up export rows from r 3.3"
      reversed_value_to_row = ExportConversionValue.find_by_value_to("Encephalitis, post-other")
      reversed_value_to_row.destroy unless reversed_value_to_row.nil?
      reversed_value_to_row = ExportConversionValue.find_by_value_to("Legionellosis")
      reversed_value_to_row.destroy unless reversed_value_to_row.nil?

      say "Load export data"
      ruby "#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/script/load_cdc_export_data.rb"
    end
  end

  def self.down
  end
end
