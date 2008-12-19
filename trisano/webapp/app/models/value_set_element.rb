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

class ValueSetElement < FormElement
  
  has_many :value_elements, 
    :class_name => "FormElement",
    :foreign_key => :parent_id,
    :dependent => :destroy
  
  after_update :save_all_value_elements
  
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
    
    super { save_new_value_elements }
  end
  
  def new_value_element_attributes=(value_attributes)
    @new_value_elements = []
    value_attributes.each do |attributes|
      value = ValueElement.new(attributes)
      @new_value_elements << value
    end
  end
    
  def existing_value_element_attributes=(value_attributes)
    value_elements.reject(&:new_record?).each do |value_element|
      attributes = value_attributes[value_element.id.to_s]
      if attributes
        value_element.attributes = attributes
      else
        value_elements.delete(value_element)
      end
    end
  end
  
  private
  
  def save_new_value_elements
    unless @new_value_elements.nil?
      @new_value_elements.each do |a|
        a.form_id = self.form_id
        a.tree_id = self.tree_id
        a.save
        self.add_child a
      end
    end
  end
  
  def save_all_value_elements
    value_elements.each do |value_element|
      value_element.save(false)
    end
    save_new_value_elements
  end
  
end
