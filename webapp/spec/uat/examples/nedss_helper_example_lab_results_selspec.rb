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
#$dont_kill_browser = true

describe "trisano_helper_example_lab_results_selspec" do 

  before(:all) do
    @cmr_name = get_unique_name(1)  
  end
  
  before(:each) do
    #put any setup tasks here
  end
  
  it "should create a CMR with 3 lab results" do 
    @browser.open("/trisano/cmrs")
    @browser.click("link=New CMR")
    @browser.wait_for_page_to_load($load_time)
    @browser.type("event_active_patient__active_primary_entity__person_last_name", @cmr_name)
    @browser.click_core_tab(@browser, "Laboratory")
    @browser.type("event_lab_result_lab_result_text", "Lab Result 1")
    @browser.select("event_lab_result_specimen_source_id", "label=Blood")
    @browser.click("event_submit")
    @browser.wait_for_page_to_load($load_time)
    @browser.click("edit_cmr_link")
    @browser.wait_for_page_to_load($load_time)
    @browser.click_core_tab(@browser, "Laboratory")
    @browser.click("link=New Lab Result")
    sleep 2 #because the following doesn't currently work
    #wait_for_element_present("new-lab-result-form")
    @browser. type("lab_result_lab_result_text", "Lab result 2")
    @browser.select("lab_result_specimen_source_id", "label=Eye Swab/Wash")
    @browser.click("save-button")
    @browser.click("link=New Lab Result")
    sleep 2
    #wait_for_element_present("new-lab-result-form")
    @browser. type("lab_result_lab_result_text", "Lab result 2")
    @browser.select("lab_result_specimen_source_id", "label=Nasopharyngeal Swab")
    @browser.click("save-button")
    @browser.click("event_submit")
    @browser.wait_for_page_to_load($load_time)
    @browser.click_core_tab(@browser, "Laboratory")
  end
  
  it "should click the second lab result" do
    click_link_by_order(@browser, "edit-lab-result", 2)
  end
end
