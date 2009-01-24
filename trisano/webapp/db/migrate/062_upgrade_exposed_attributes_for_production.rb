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

class UpgradeExposedAttributesForProduction < ActiveRecord::Migration
  def self.up
    
    if RAILS_ENV == "production"
      transaction do
        say "Upgrading form elements: Updating core field configs and core follow up with new core paths."
        
        FormElement.find_by_sql("select * from form_elements where type = 'CoreFieldElement' or type = 'FollowUpElement' and core_path is not null;").each do |element|
          unless element.core_path.index(/^event\[/).nil?
            say "Upgrading form element #{element.id}, core path of #{element.core_path}"
            element.core_path = element.core_path.sub(/^event\[/, "morbidity_event[")
            element.save!
            say "New core path = #{element.core_path}"
          end
          
        end
      end
    end
    
  end

  def self.down
  end
end
