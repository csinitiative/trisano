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
$dont_kill_browser = true

describe "lab results helper" do
  it "should add a lab result to an existing CMR" do
    @lab_result_fields = {
      "lab_result_lab_result_text" => get_unique_name(2),
      "lab_result_specimen_source_id" => "Cervical Swab",
      "lab_result_collection_date" => "5/12/2008",
      "lab_result_lab_test_date" => "5/15/2008",
      "lab_result_specimen_sent_to_state_id" => "Yes"
    }
    @browser.open("/trisano/cmrs")
    @browser.click("link=Edit")
    @browser.wait_for_page_to_load($load_time)
    @browser.click("link=New Lab Result")
    sleep 3
    set_fields(@browser, @lab_result_fields)
    @browser.click("save-button")
    sleep 3
    @browser.click('event_submit')
    @browser.wait_for_page_to_load($load_time)
  end
end

