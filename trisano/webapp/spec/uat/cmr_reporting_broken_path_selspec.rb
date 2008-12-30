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

require File.dirname(__FILE__) + '/spec_helper'

describe 'invalid cmr' do
  #$dont_kill_browser = true
  
  before(:all) do
    @browser.open "/trisano/cmrs"
    @browser.click("link=NEW CMR")
    @browser.wait_for_page_to_load
  end

  it 'should preserve the reporting agency field data' do
    click_core_tab(@browser, REPORTING)
    @browser.click("//a[@id='add_reporting_agency_link']")
    @browser.type("//input[@id='morbidity_event_active_reporting_agency_name']", 'The Venture Compound')
    @browser.check("//div[@id='reporting_agency']//input[@id='School']")
    save_and_continue(@browser)
    click_core_tab(@browser, REPORTING)
    @browser.get_value("//input[@id='morbidity_event_active_reporting_agency_name']").should == 'The Venture Compound'
    @browser.is_checked("//div[@id='reporting_agency']//input[@id='School']").should == true
  end
end
