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

require File.dirname(__FILE__) + '/../../spec_helper'
  include ExternalCodesHelper

describe "/external_codes/index.html.haml" do

  before(:each) do

    cn1 = mock_model(CodeName)
    cn1.stub!(:code_name).and_return('test1')
    cn1.stub!(:description).and_return('Test 1')
    cn1.stub!(:external).and_return(true)

    cn2 = mock_model(CodeName)
    cn2.stub!(:code_name).and_return('test2')
    cn2.stub!(:description).and_return('Test 2')
    cn2.stub!(:external).and_return(true)

    assigns[:code_names] = [cn1, cn2]
  end
  
  it "should render list of code types/names" do
    render "/external_codes/index.html.haml"
  end
end

