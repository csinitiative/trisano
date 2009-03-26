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

class ValueSetElement < FormElement
  
  has_many :value_elements, 
    :class_name => "FormElement",
    :foreign_key => :parent_id,
    :dependent => :destroy
  
  validates_presence_of :name
  
  attr_accessor :parent_element_id
  
  def save_and_add_to_form
    begin
      parent_element = FormElement.find(parent_element_id)
      unless parent_element.can_receive_value_set?
        self.errors.add_to_base("A question can only have one value set")
        return nil
      end
    rescue Exception => ex
      self.errors.add_to_base("An error occurred checking the parent for existing value set children")
      return nil
    end
    
    super
  end
  
end