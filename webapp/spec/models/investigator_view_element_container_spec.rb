# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

describe InvestigatorViewElementContainer do
  before(:each) do
    @investigator_view_element_container = InvestigatorViewElementContainer.new
  end

  it "should be valid" do
    @investigator_view_element_container.should be_valid
  end
  
    it "should return nil for save_and_add_to_form" do
    @investigator_view_element_container.save_and_add_to_form.should be_nil
  end
  
end
