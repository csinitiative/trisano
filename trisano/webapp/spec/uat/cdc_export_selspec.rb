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
 
describe 'Admin CDC Export' do
  
  # $dont_kill_browser = true

  before :all do
    @browser.open "/trisano/cmrs"
    @unique_name = get_unique_name(1)
  end
  
  it "should create a basic cmr" do
    create_basic_investigatable_cmr(@browser, @unique_name, 'AIDS', "Bear River Health Department") do |browser|
      browser.select("morbidity_event_udoh_case_status_id", "label=Probable")
    end.should be_true
  end

  it "should display a link for cdc export" do
    @browser.click("link=ADMIN")
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('CDC Export').should be_true
  end

  it "should produce a cdc record for the cmr" do
    @browser.click("link=CDC Export")
    @browser.wait_for_page_to_load($load_time)
    @browser.get_html_source.gsub(/<\/?[^>]*>/, "")[17..21].should == '10560'
  end
    
  it "should not produce cdc record for next export" do
    @browser.go_back
    @browser.wait_for_page_to_load($load_time)
    @browser.click("link=CDC Export")
    @browser.wait_for_page_to_load($load_time)
    @browser.get_html_source.gsub(/<\/?[^>]*>/, "").length.should == 0
  end

  it "should update imported from" do
    @browser.go_back
    @browser.wait_for_page_to_load($load_time)
    @browser.click("link=CMRS")
    @browser.wait_for_page_to_load($load_time)
    edit_cmr(@browser).should be_true
    @browser.select("morbidity_event_imported_from_id", "Outside U.S.")
    save_cmr(@browser).should be_true
  end

  it "should produce cdc record for cmr" do
    @browser.click("link=ADMIN")
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('CDC Export').should be_true    
    @browser.click("link=CDC Export")
    @browser.wait_for_page_to_load($load_time)
    @browser.get_html_source.gsub(/<\/?[^>]*>/, "")[17..21].should == '10560'
  end
end
