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

require "migration_helpers"

class AddContactDispositionToPeople < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    add_column(:people, :disposition_id, :integer)    
    
    if RAILS_ENV == 'production'
      transaction do
        say 'Adding defaault contact dispostion codes to external_codes table'

        [{:code_description => 'Preventative treatment', :the_code => 'PT'},
         {:code_description => 'Refused preventative treatment', :the_code => 'RPT'},
         {:code_description => 'Infected, brought to treatment', :the_code => 'IBT'},
         {:code_description => 'Infected, not treated', :the_code => 'INT'},
         {:code_description => 'Previously treated for this infection', :the_code => 'PTFTI'},
         {:code_description => 'Not infected', :the_code => 'NI'},
         {:code_description => 'Insufficient information to begin investigation', :the_code => 'IIBI'},
         {:code_description => 'Unable to locate', :the_code => 'UTL'},
         {:code_description => 'Located, refused exam and/or treament', :the_code => 'LR'},
         {:code_description => 'Out of jurisdiction', :the_code => 'OOJ'},
         {:code_description => 'Other', :the_code => 'O'}
        ].each_with_index do |type, i|
          ExternalCode.create!(type.merge(:sort_order => i*10, :code_name => 'contactdispositiontype'))
        end
      end
    end
    
    add_foreign_key(:people, :disposition_id, :external_codes)
  end

  def self.down
    remove_foreign_key(:people, :disposition_id)
    if RAILS_ENV == 'production'
      ExternalCode.delete_all :code_name => 'contactdispositiontype'
    end
    remove_column(:people, :disposition_id)    
  end
end
