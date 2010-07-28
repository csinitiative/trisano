class RenameCdcDiseaseExportStatusTable < ActiveRecord::Migration
  def self.up
    rename_table :diseases_external_codes, :cdc_disease_export_statuses
  end

  def self.down
    rename_table :cdc_disease_export_statuses, :diseases_external_codes
  end
end
