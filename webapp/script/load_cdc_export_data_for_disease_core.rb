# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the 
# terms of the GNU Affero General Public License as published by the 
# Free Software Foundation, either version 3 of the License, 
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

puts "Loading CDC disease-core export data (script/load_cdc_export_data_for_disease_core.rb)"

export_columns = YAML::load_file("#{RAILS_ROOT}/db/defaults/export_columns_disease_core.yml")
export_conversion_values = YAML::load_file("#{RAILS_ROOT}/db/defaults/export_conversion_values_disease_core.yml")
disease_code_groups = YAML::load_file("#{RAILS_ROOT}/db/defaults/disease_code_groups.yml")


ExportColumn.transaction do
  export_columns.each do |ec|

    export_name = ExportName.find_by_export_name(ec['export_name'])
    raise "Could not find an export name for the export column" if export_name.nil?

    # If disease code group is blank, we're dealing with a core or fixed export value
    if ec['disease_code_group'].blank?
      export_column = ExportColumn.find_or_initialize_by_export_column_name(
        :type_data => ec['type_data'],
        :export_column_name => ec['export_column_name'],
        :table_name => ec['table_name'],
        :column_name => ec['column_name'],
        :is_required => ec['is_required'],
        :start_position => ec['start_position'],
        :length_to_output => ec['length_to_output'],
        :export_name_id => export_name.id,
        :name => ec['name'],
        :data_type => ec['data_type']
      )
      # Otherwise, we need to find export columns by name and disease group ID, because names are
      # not unique across all diseases.
    else
      export_disease_group = ExportDiseaseGroup.find_by_name(ec['disease_code_group'])
      raise "Could not find export disease group" if export_disease_group.nil?
       
      export_column = ExportColumn.find_or_initialize_by_type_data_and_export_column_name_and_export_disease_group_id(
        :type_data => ec['type_data'],
        :export_column_name => ec['export_column_name'],
        :export_disease_group_id => export_disease_group.id,
        :table_name => ec['table_name'],
        :column_name => ec['column_name'],
        :is_required => ec['is_required'],
        :start_position => ec['start_position'],
        :length_to_output => ec['length_to_output'],
        :export_name_id => export_name.id,
        :name => ec['name'],
        :data_type => ec['data_type']
      )
    end
    
    if export_column.new_record?
      export_column.save!

      disease_code_group = disease_code_groups.find {|d| d["disease"] == ec['disease_code_group'] }
      disease_codes = disease_code_group["codes"].split("|").uniq

      disease_codes.each do |disease_code|
        disease = Disease.find_by_cdc_code(disease_code)

        unless disease.nil?
          disease.export_columns << export_column
        end
      end

      # Find the export conversion values for this disease group and export column name
      conversion_values = export_conversion_values.find_all do |ecv|
        (ecv['disease_code_group'] == ec['disease_code_group']) && (export_column.export_column_name == ecv['export_column_name'])
      end
        
      conversion_values.each do |conversion_value|
        export_conversion_value = ExportConversionValue.find_or_initialize_by_export_column_id_and_value_from_and_value_to(
          :export_column_id => export_column.id,
          :value_from => conversion_value['value_from'],
          :value_to => conversion_value['value_to'],
          :sort_order => conversion_value['sort_order']
        )
    
        export_conversion_value.save! if export_conversion_value.new_record?
      end
      
    end
    
  end
end
