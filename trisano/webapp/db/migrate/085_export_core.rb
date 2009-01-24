# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

class ExportCore < ActiveRecord::Migration
  def self.up
 
    #execute "Create Language plpgsql"
    
    create_table :export_names do |t|
      t.string :export_name, :limit=> 50   #  name of the export data set
      t.timestamps
    end

    create_table :export_columns do |t|
      t.integer :export_name_id     #  from export_names.id
      t.string :type_data, :limit => 10  # core or form
      t.string :export_column_name, :limit => 20  #user defined what name they want exported to
      t.string :table_name, :limit=>100   #  table name from the core data tables (events, people, etc.)
      t.string :column_name, :limit=>100  #  column name within above table_name to be exported  (birth_gender_id)
      t.string :is_required, :limit=>1  #  Y= yes, N=no
      t.integer :start_position   #  start at postition 25
      t.integer :length_to_output    #  for 4 positions 
      t.timestamps
    end
    
    execute "ALTER TABLE export_columns
		ADD CONSTRAINT  fk_exportnames FOREIGN KEY (export_name_id) REFERENCES export_names (id)"

    create_table :export_conversion_values do |t|
      t.integer :export_column_id     #  from export_columns.id
      t.string  :value_from           #  From Value  (for example, Pregnant Y )
      t.string  :value_to             #  To value    (for example, Pregnant 1  required for CDC )
      t.timestamps
    end      
    execute "ALTER TABLE export_conversion_values
		ADD CONSTRAINT  fk_exportcols FOREIGN KEY (export_column_id) REFERENCES export_columns (id)"

    create_table :export_predicates  do |t|
      t.string :table_name, :limit=>100     # table name from the core data tables (events, people, etc.)
      t.string :column_name, :limit=>100    # column name within the above table_name to be used in the WHERE clause
      t.string :comparison_operator, :limit=>20   # the operator that will be used (=, <>, =>, =<, etc)
      t.string :comparison_value, :limit=>80      # the value applied to the operator (28, '10/01/2008')
      t.string :comparison_logical, :limit=>5     # are there going to be more?  (AND, OR)
      t.integer :export_name_id
      t.timestamps
    end

    execute "ALTER TABLE export_predicates
		ADD CONSTRAINT  fk_pred_exportname  FOREIGN KEY (export_name_id) REFERENCES export_names (id)"
    
    
    create_table :cdc_exports do |t|
      t.string :type_data, :limit=>10
      t.string :export_column_name, :limit=>200
      t.string :is_required, :limit=>1
      t.integer  :start_position
      t.integer  :length_to_output
      t.string  :table_name, :limit=>100
      t.string  :column_name, :limit=>100
    end

  end

  def self.down
    
    execute "ALTER TABLE export_conversion_values
                DROP CONSTRAINT fk_exportcols"
    execute "ALTER TABLE export_columns
                DROP CONSTRAINT fk_exportnames"
    execute "ALTER TABLE export_predicates
		DROP CONSTRAINT  fk_pred_exportname"

    drop_table :export_predicates
    drop_table :export_conversion_values
    drop_table :export_columns
    drop_table :export_names
    drop_table :cdc_exports

    
  end
end
