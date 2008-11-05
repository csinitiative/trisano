# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

export_names = YAML::load_file("#{RAILS_ROOT}/db/defaults/export_names.yml")
export_columns = YAML::load_file("#{RAILS_ROOT}/db/defaults/export_columns.yml")

ExportName.transaction do
  export_names.each do |export_name|
    export_name = ExportName.find_or_initialize_by_export_name(:export_name => export_name['export_name'])
    export_name.save! if export_name.new_record?
  end
end

ExportColumn.transaction do
  export_columns.each do |export_column|
    export_name = ExportName.find_by_export_name(export_column['export_name'])
    raise "Could not find an export name for the export column" if export_name.nil?
    
    export_column = ExportColumn.find_or_initialize_by_export_column_name(
      :type_data => export_column['type_data'],
      :export_column_name => export_column['export_column_name'],
      :table_name => export_column['table_name'],
      :column_name => export_column['column_name'],
      :is_required => export_column['is_required'],
      :start_position => export_column['start_position'],
      :length_to_output => export_column['length_to_output'],
      :export_name_id => export_name.id,
      :name => export_column['name']
    )
    
    export_column.save! if export_column.new_record?
  end
end
