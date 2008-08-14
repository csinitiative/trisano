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

require File.dirname(__FILE__) + '/../../spec_helper'

describe "/value_set_elements/new.rjs" do
  include ValueSetElementsHelper
  
  before(:each) do
    value_element = mock_model(ValueElement)
    value_element.stub!(:name).and_return("Yes")
    value_element.stub!(:should_destroy).and_return("0")
    value_element.stub!(:is_active).and_return(true)
    
    @value_set_element = mock_model(ValueSetElement)
    @value_set_element.stub!(:new_record?).and_return(true)
    @value_set_element.stub!(:form_id).and_return("1")
    @value_set_element.stub!(:name).and_return("MyString")
    @value_set_element.stub!(:parent_element_id).and_return(4)
    @value_set_element.stub!(:value_elements).and_return([value_element])
    
    assigns[:value_set_element] = @value_set_element
  end

  it "should render new form" do
    render "/value_set_elements/new.rjs"
    
    response.should have_tag("form[action=?][method=post]", value_set_elements_path) do
      with_tag("input#value_set_element_name[name=?]", "value_set_element[name]")
    end
  end
end
