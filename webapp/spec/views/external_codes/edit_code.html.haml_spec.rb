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

describe "/external_codes/edit_code.html.haml" do

  before(:each) do
    cn = mock_model(CodeName)
    cn.stub!(:code_name).and_return('test')
    cn.stub!(:description).and_return('Test')
    cn.stub!(:external).and_return(true)

    code = mock_model(ExternalCode)
    code.stub!(:the_code).and_return('TEST')
    code.stub!(:code_name).and_return('test')
    code.stub!(:code_description).and_return('Test Code')
    code.stub!(:sort_order).and_return(1)
    code.should_receive(:deleted?).at_least(:once).and_return(false)

    assigns[:code_name] = cn
    assigns[:external_code] = code
  end
  
  it "should render edit form for test code" do
    render "/external_codes/edit_code.html.haml"
  end
end

