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

require File.dirname(__FILE__) + '/spec_helper'
require 'active_support'

describe 'Adding multiple treatments to a CMR' do
  
  # $dont_kill_browser = true
  
  before(:all) do
    @browser.open "/trisano/cmrs"
    @browser.wait_for_page_to_load($load_time)
  end
  
  it "should allow multiple treatments to be saved with a new CMR" do
    display_date = 10.days.ago.strftime('%B %d, %Y')

    click_nav_new_cmr(@browser).should be_true
    @browser.type "//input[contains(@id, 'last_name')]", "multi-treatments"
    @browser.type "//input[contains(@id, 'first_name')]", "test"

    click_core_tab(@browser, "Clinical")
    @browser.click "link=Add a Treatment"
    sleep(1)

    add_treatment(@browser, {:treatment => "Leeches", :treatment_given => "label=Yes", :treatment_date => display_date})

    save_cmr(@browser).should be_true
    edit_cmr(@browser).should be_true

    add_treatment(@browser, {:treatment => "Whiskey", :treatment_given => "label=Yes", :treatment_date => display_date}, 2)
    save_cmr(@browser).should be_true

    @browser.is_text_present("Leeches").should be_true
    @browser.is_text_present("Whiskey").should be_true
  end

  it "should allow removing a treatement" do
    edit_cmr(@browser)
    click_core_tab(@browser, "Clinical")
    @browser.check "//div[@id='treatments']//input[contains(@id, '_delete')]"
    save_cmr(@browser).should be_true
    @browser.is_text_present("Leeches").should_not be_true
  end

  it "should allow editing a treatemt" do
    edit_cmr(@browser)
    @browser.type "//input[@value='Whiskey']", "Eye of newt"
    click_core_tab(@browser, "Clinical")
    save_cmr(@browser).should be_true
    @browser.is_text_present('Eye of newt').should be_true
  end

end
