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

require File.dirname(__FILE__) + '/spec_helper' 

describe "test2" do
  before(:each) do
    #put any setup tasks here
  end
  it "describe what this thing should do here" do 
    @browser.open "/trisano/"
    @browser.click "link=Forms"
    @browser.wait_for_page_to_load($load_time)
    click_resource_edit(@browser, "forms", "Marge Not There").should == -1
    click_resource_show(@browser, "forms", get_unique_name(4)).should == -1
  end
end
