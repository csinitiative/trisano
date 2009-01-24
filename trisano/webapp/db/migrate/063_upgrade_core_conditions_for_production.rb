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

class UpgradeCoreConditionsForProduction < ActiveRecord::Migration
  def self.up
    
    if RAILS_ENV == "production"
      transaction do
        say "Upgrading form elements: Updating core conditions for existing core follow ups"
        FormElement.find_by_sql("select * from form_elements where type = 'FollowUpElement' and core_path is not null and is_condition_code is null;").each do |element|
          unless (element.condition.to_i == 0)
            begin
              say "Checking for a matching code for FollowUpElement #{element.id}"
              code = ExternalCode.find(element.condition)
              say "Found a match: #{code.code_description}. Upgrading to code condition."
              element.is_condition_code = true
              element.save!
            rescue Exception => ex
              say "No matching code for #{element.condition}. Leaving as is."
              # No-op -- No code match
            end
          end
        end
      end
    end
    
  end

  def self.down
  end
end
