class AddBloodCsfSpecimenExportConversionValues < ActiveRecord::Migration
  def self.up
    c = ExportColumn.find_by_export_column_name("SPECIMEN SITE")
    if c
      ExportConversionValue.find_or_create_by_export_column_id_and_value_from_and_value_to_and_sort_order(c.id, "Blood/Serum", "13", 15)
      ExportConversionValue.find_or_create_by_export_column_id_and_value_from_and_value_to_and_sort_order(c.id, "Cerebrospinal fluid (CSF)", "14", 16)
    end
  end

  def self.down
    c = ExportColumn.find_by_export_column_name("SPECIMEN SITE")
    if c
      v = ExportConversionValue.find_by_export_column_id_and_value_from_and_value_to_and_sort_order(c.id, "Blood/Serum", "13", 15)
      v.delete if v

      v = ExportConversionValue.find_by_export_column_id_and_value_from_and_value_to_and_sort_order(c.id, "Cerebrospinal fluid (CSF)", "14", 16)
      v.delete if v
    end
  end
end