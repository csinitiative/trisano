class AddSpecimenExportConversionValues < ActiveRecord::Migration
  def self.up
    c = ExportColumn.find_by_export_column_name("SPECIMEN SITE")
    if c
      ExportConversionValue.find_or_create_by_export_column_id_and_value_from_and_value_to_and_sort_order(c.id, "Blood/Serum", "13", 13)
      ExportConversionValue.find_or_create_by_export_column_id_and_value_from_and_value_to_and_sort_order(c.id, "Cerebrospinal fluid (CSF)", "14", 14)
    end
  end

  def self.down
    c = ExportColumn.find_by_export_column_name("SPECIMEN SITE")
    if c
      v = ExportConversionValue.find_by_export_column_id_and_value_from_and_value_to_and_sort_order(c.id, "Blood/Serum", "13", 13)
      v.delete if v

      v = ExportConversionValue.find_by_export_column_id_and_value_from_and_value_to_and_sort_order(c.id, "Cerebrospinal fluid (CSF)", "14", 14)
      v.delete if v
    end
  end
end
