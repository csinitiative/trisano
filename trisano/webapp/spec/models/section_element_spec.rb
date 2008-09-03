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

require File.dirname(__FILE__) + '/../spec_helper'

describe SectionElement do
  before(:each) do
    @section_element = SectionElement.new
    @section_element.name="Section 1"
  end

  it "should be valid" do
    @section_element.should be_valid
  end
  
  describe "when created with 'save and add to form'" do
    
    it "should be a child of the form's investigator element container" do
      form = Form.new(:name => "Test Form")
      form.save_and_initialize_form_elements
      
      @section_element.parent_element_id = form.investigator_view_elements_container.id
      @section_element.save_and_add_to_form
      @section_element.parent_id.should_not be_nil
      form.investigator_view_elements_container.children[1].id.should == @section_element.id
    end
    
    it "should be receive a tree id" do
      form = Form.new(:name => "Test Form")
      form.save_and_initialize_form_elements
      
      @section_element.parent_element_id = form.investigator_view_elements_container.id
      @section_element.save_and_add_to_form
      
      @section_element.tree_id.should_not be_nil
      @section_element.tree_id.should eql(form.form_base_element.tree_id)
    end
    
  end
  
end