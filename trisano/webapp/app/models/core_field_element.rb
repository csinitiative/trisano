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

class CoreFieldElement < FormElement
  
  attr_accessor :parent_element_id
  validates_presence_of :core_path
  validates_presence_of :name
  
  def save_and_add_to_form
    self.name = Event.exposed_attributes[self.core_path][:name]
    super do
      before_core_field_element = BeforeCoreFieldElement.create(:tree_id => self.tree_id, :form_id => self.form_id)
      after_core_field_element = AfterCoreFieldElement.create(:tree_id => self.tree_id, :form_id => self.form_id)
      self.add_child(before_core_field_element)
      self.add_child(after_core_field_element)
    end
  end
  
  def available_core_fields
    return nil if parent_element_id.blank?
    parent_element = FormElement.find(parent_element_id)
    
    fields_in_use = []
    parent_element.children_by_type("CoreFieldElement").each { |field| fields_in_use << field.name }
    
    available_core_fields = []
    Event.exposed_attributes.each do |attribute|
      unless (fields_in_use.include?(attribute[1][:name]))
        field_attributes = [attribute[1][:name], attribute[0]]
        available_core_fields << field_attributes
      end
    end
    
    available_core_fields.sort
  end
  
end
