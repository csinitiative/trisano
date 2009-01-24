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

class AddCoreFieldContainersForProduction < ActiveRecord::Migration
  def self.up
    
    if RAILS_ENV == "production"
      transaction do
        say "Upgrading forms: Adding core field element containers to forms that need them."
        
        Form.find(:all).each do |form|
          form_base_element = form.form_base_element  
          if (form_base_element.children_count == 2)
            say "Upgrading form #{form.id} -- #{form.name}"
            form_base_element.add_child(CoreFieldElementContainer.create({
                  :form_id => form_base_element.form_id, 
                  :tree_id => form_base_element.tree_id 
                }
              )
            )
          end
        end
      end
    end
    
  end

  def self.down
  end
end
