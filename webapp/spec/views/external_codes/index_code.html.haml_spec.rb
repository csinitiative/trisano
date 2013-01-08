# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

describe "/external_codes/index_code.html.haml" do

  before(:each) do
    cn = Factory.build(:code_name)
    cn.stubs(:code_name).returns('test')
    cn.stubs(:description).returns('Test')
    cn.stubs(:external).returns(true)

    code = Factory.build(:external_code)
    code.stubs(:the_code).returns('TEST')
    code.stubs(:code_name).returns('test')
    code.stubs(:code_description).returns('Test Code')
    code.stubs(:sort_order).returns(1)
    code.expects(:deleted?).at_least(1).returns(false)

    assigns[:code_name] = cn
    assigns[:external_codes] = [code]
  end
  
  it "should render list of codes for test " do
    render "/external_codes/index_code.html.haml"
  end
end

