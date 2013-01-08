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
describe "TrisanoHelper tab navigation" do 
  before(:each) do
    #put any setup tasks here
  end
  it "should find each tab" do 
    @browser.open "/trisano/cmrs"
    @browser.click("link=New CMR")
    @browser.wait_for_page_to_load($load_time)
    click_core_tab(@browser, "Clinical")
    @browser.is_text_present("Disease Information").should be_true
    click_core_tab(@browser, "Laboratory")
    @browser.is_text_present("Lab Result").should be_true
    click_core_tab(@browser, "Epidemiological")
    @browser.is_text_present("Food handler").should be_true
    click_core_tab(@browser, "Reporting")
    @browser.is_text_present("Reporting Agency").should be_true
    click_core_tab(@browser, "Administrative")
    @browser.is_text_present("Jurisdiction").should be_true
    @browser.select("event_event_status_id", "label=Under Investigation")
    click_core_tab(@browser, "Demographics")
    @browser.is_text_present("Person Information").should be_true
    click_core_tab(@browser, "Contacts")
    @browser.is_text_present("Add a New Contact").should be_true
    @browser.type("event_active_patient__active_primary_entity__person_last_name", "Tester")
    @browser.type("event_active_patient__active_primary_entity__person_first_name", "Tab")
    @browser.click("event_submit")
    @browser.wait_for_page_to_load($load_time)
    click_core_tab(@browser, "Investigation")
    @browser.is_text_present("Investigative Information").should be_true
  end
end
