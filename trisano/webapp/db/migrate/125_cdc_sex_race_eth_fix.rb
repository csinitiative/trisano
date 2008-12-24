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
require 'migration_helpers'

class CdcSexRaceEthFix < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    transaction do
      script_dir = File.join(File.dirname(__FILE__), '..', 'scripts', '125')
      execute(IO.read(File.join(script_dir,'thebigcdcsql.sql')))
      load_conversion_values if RAILS_ENV =~ /production/
    end
  end

  def self.down
    transaction do
      script_dir = File.join(File.dirname(__FILE__), '..', 'scripts', '114')
      execute(IO.read(File.join(script_dir,'thebigcdcsql.sql')))
    end
  end

  def self.load_conversion_values
    load_ethnic_conversions
    load_race_conversions
    load_sex_conversions
  end

  def self.load_ethnic_conversions
    a = [{:value_from => 'H', :value_to => '1'},
         {:value_from => 'O', :value_to => '2'},
         {:value_from => 'NH', :value_to => '2'},
         {:value_from => 'UNK', :value_to => '9'},
         {:value_from => 'U', :value_to => '9'}
        ]
    load_conversions('ethnicity_id', a)
  end

  def self.load_race_conversions
    a = [{:value_from => 'B', :value_to => '3'},
         {:value_from => 'AA', :value_to => '1'},
         {:value_from => 'A', :value_to => '2'},
         {:value_from => 'AK', :value_to => '1'},
         {:value_from => 'H', :value_to => '2'},
         {:value_from => 'W', :value_to => '5'},
         {:value_from => 'UNK', :value_to => '9'}
        ]
    load_conversions('race_id', a)
  end

  def self.load_sex_conversions
    a = [{:value_from => 'M', :value_to => '1'},
         {:value_from => 'F', :value_to => '2'},
         {:value_from => 'UNK', :value_to => '9'}
        ]
    load_conversions('birth_gender_id', a)
  end

  def self.load_conversions(column, conversions)
    id = export_column_get(column)
    conversions.each { |h| export_conversion_for(id, h) }
  end

  def self.export_column_get(name)
    ExportColumn.find_by_column_name(name).id
  end

  def self.export_conversion_for(export_column_id, values_hash)
    cv = ExportConversionValue.find_or_create_by_export_column_id_and_value_from(export_column_id, values_hash[:value_from])
    cv.update_attributes(values_hash)
  end
end
