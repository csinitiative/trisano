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

require File.dirname(__FILE__) + '/spec_helper'

#$dont_kill_browser = true

describe 'Adding multiple lab results to a CMR' do
  
  it "should allow adding new lab results to a new CMR" do
    @browser.open("/trisano/cmrs")
    create_simplest_cmr(@browser, get_unique_name(1))
    edit_cmr(@browser).should be_true

    click_core_tab(@browser, "Laboratory")
    @browser.click "link=Add a new lab result to this lab"
    wait_for_element_present("//div[@id='labs']/div[@class='lab'][1]//div[contains(@class, 'lab_result')][2]//input[contains(@name, 'test_type')]")
    @browser.click "link=Add a new lab"
    wait_for_element_present("//div[@id='labs']/div[@class='lab'][2]//input[contains(@name, 'name')]")

    @browser.type "//div[@id='labs']/div[@class='lab'][1]//input[contains(@name, 'name')]", "Lab One"
    @browser.type "//div[@id='labs']/div[@class='lab'][1]//div[contains(@class, 'lab_result')][1]//input[contains(@name, 'test_type')]", "Urinalysis"
    @browser.type "//div[@id='labs']/div[@class='lab'][1]//div[contains(@class, 'lab_result')][1]//input[contains(@name, 'lab_result_text')]", "Positive"

    @browser.type "//div[@id='labs']/div[@class='lab'][1]//div[contains(@class, 'lab_result')][2]//input[contains(@name, 'test_type')]", "Blood Test"
    @browser.type "//div[@id='labs']/div[@class='lab'][1]//div[contains(@class, 'lab_result')][2]//input[contains(@name, 'lab_result_text')]", "Negative"

    @browser.type "//div[@id='labs']/div[@class='lab'][2]//input[contains(@name, 'name')]", "Lab Two"
    @browser.type "//div[@id='labs']/div[@class='lab'][2]//div[contains(@class, 'lab_result')][1]//input[contains(@name, 'test_type')]", "Biopsy"
    @browser.type "//div[@id='labs']/div[@class='lab'][2]//div[contains(@class, 'lab_result')][1]//input[contains(@name, 'lab_result_text')]", "Inconclusive"

    save_cmr(@browser).should be_true

    @browser.is_text_present('Lab One').should be_true
    @browser.is_text_present('Lab Two').should be_true
    @browser.is_text_present('Positive').should be_true
    @browser.is_text_present('Negative').should be_true
    @browser.is_text_present('Inconclusive').should be_true
    @browser.is_text_present('Urinalysis').should be_true
    @browser.is_text_present('Blood Test').should be_true
    @browser.is_text_present('Biopsy').should be_true
  end

  it "should allow editing a lab name" do
    edit_cmr(@browser).should be_true
    old_lab_name = @browser.get_value("//div[@id='labs']/div[1]//input[contains(@name, 'name')]")
    lab_name = get_unique_name(3)
    @browser.type("//div[@id='labs']/div[1]//input[contains(@name, 'name')]", "")
    @browser.type_keys("//div[@id='labs']/div[1]//input[contains(@name, 'name')]", lab_name)
    save_cmr(@browser).should be_true
    @browser.is_text_present(lab_name).should be_true
    @browser.is_text_present(old_lab_name).should_not be_true
  end

  it "should allow editing lab results" do
    edit_cmr(@browser).should be_true
    test_type = get_unique_name(2)
    @browser.type "//div[@id='labs']/div[@class='lab'][1]//div[contains(@class, 'lab_result')][1]//input[contains(@name, 'test_type')]", test_type
    save_cmr(@browser).should be_true
    @browser.is_text_present(test_type).should be_true
  end

  it "should allow removing individual lab results" do
    edit_cmr(@browser).should be_true
    lab_name_1 = @browser.get_value("//div[@id='labs']/div[@class='lab'][1]//input[contains(@name, 'name')]")
    lab_name_2 = @browser.get_value("//div[@id='labs']/div[@class='lab'][2]//input[contains(@name, 'name')]")
    # Targets the 2nd lab result of the first lab to have 2 or more lab results
    test_type = @browser.get_value("//div[@id='labs']/div[@class='lab']//div[contains(@class, 'lab_result')][2]//input[contains(@name, 'test_type')]")
    p "Here it comes the delete of..."
    p test_type
    sleep(3)
    @browser.click("//div[@id='labs']/div[@class='lab']//div[contains(@class, 'lab_result')][2]//a[@id='remove_lab_result_link']")
    p "All gone?"
    sleep(3)
    p "Saving"
    save_cmr(@browser).should be_true
    @browser.is_text_present(test_type).should_not be_true
    @browser.is_text_present(lab_name_1).should be_true
    @browser.is_text_present(lab_name_2).should be_true
    p "Waddya see?"
    sleep(3)
  end

  it "should allow deleting a lab and all its lab results" do
    edit_cmr(@browser).should be_true
    lab_name = @browser.get_value("//div[@id='labs']/div[@class='lab'][2]//input[contains(@name, 'name')]")
    @browser.click("//div[@id='labs']/div[@class='lab'][2]/span/a[@id='remove_lab_link']")
    save_cmr(@browser).should be_true
    @browser.is_text_present(lab_name).should_not be_true
  end
end
