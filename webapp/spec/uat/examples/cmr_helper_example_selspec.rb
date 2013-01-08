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

require File.dirname(__FILE__) + './spec_helper' 
$dont_kill_browser = true

describe "cmr helper example" do 
  before(:each) do
    #put any setup tasks here
  end
  
  before(:each) do
    #put any setup tasks here
  end
  
  it "should create a cmr from a hash of field names and values" do 
    @browser.open("/trisano/forms")
    @browser.wait_for_page_to_load("30000")
    cmr_hash = get_full_cmr_hash()
    create_cmr_from_hash(@browser, cmr_hash)
  end
end














