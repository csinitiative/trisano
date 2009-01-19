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

describe 'CDC export follow ups' do
  
  # $dont_kill_browser = true

  before :all do
    @browser.open "/trisano/cmrs"
    @field_name = "Gestation #{get_unique_name(1)}"
  end

  it 'should add mumps form and core cdc follow up to cdc output' do
    @browser.click("link=FORMS")
    @browser.wait_for_page_to_load
    @browser.click("//input[@value='Create new form']")
    @browser.wait_for_page_to_load
    @browser.type("//input[@id='form_name']", "mumpy #{get_unique_name(1)}")
    @browser.select("//select[@id='form_event_type']", "Morbidity event")
    @browser.check("//input[@id='Mumps']")
    @browser.click("//input[@value='Create']")
    @browser.wait_for_page_to_load
    @browser.click("//a[text()='Detail']")
    @browser.wait_for_page_to_load
    @browser.click("//a[@id='add-core-field']")
    wait_for_element_present("//b[text()='Add Core Field']")
    @browser.select("//select[@id='core_field_element_core_path']", "Pregnant")
    @browser.click("//input[@value='Create']")
    wait_for_element_present("//a[text()='Add follow up to after config']")
    @browser.click("//a[text()='Add follow up to after config']")
    wait_for_element_present("//label[text()='Condition']")
    @browser.type("//input[@name='follow_up_element[condition]']", "Code: Yes (yesno)")
    @browser.select("//select[@id='follow_up_element_core_path']", "Pregnant")
    @browser.click("//input[@value='Create']")
    wait_for_element_present("//a[text()='Add question to follow up container']")
    @browser.click("//a[text()='Add question to follow up container']")
    wait_for_element_present("//label[text()='Question text']")
    @browser.type("//input[@id='question_element_question_attributes_question_text']",
                  @field_name)
    @browser.select("//select[@id='question_element_export_column_id']",
                    "Number of weeks gestation (or trimester) at onset")
    @browser.click("//input[@value='Create']")
    wait_for_element_present("//i[text()='Blank']")
    @browser.click("//input[@value='Publish']")
    @browser.wait_for_page_to_load

    # creat the cmr
    @browser.click('link=NEW CMR')
    @browser.wait_for_page_to_load
    @browser.type('morbidity_event_active_patient__person_last_name',
                  "#{get_unique_name(1)} mumpy cdc")
    click_core_tab(@browser, CLINICAL)
    @browser.select("//select[@id='morbidity_event_disease_disease_id']",
                    "Mumps")
    click_core_tab(@browser, ADMIN)
    @browser.select("morbidity_event_state_case_status_id", 'Confirmed')
    @browser.click("//input[@value='Save & Continue']")
    @browser.wait_for_page_to_load
    click_core_tab(@browser, CLINICAL)
    @browser.select("//select[@id='morbidity_event_active_patient__participations_risk_factor_pregnant_id']",
                    "Yes")
    wait_for_element_present("//label[text()='#{@field_name}']")
    @browser.select("//label[text()='#{@field_name}']/../select", "Second trimester")
    @browser.click("//input[@value='Save & Exit']")
    @browser.wait_for_page_to_load
    
    # check the cdc output
    @browser.open "/trisano/cdc_events/current_week.txt"
    @browser.wait_for_page_to_load($load_time)
    source = @browser.get_html_source.gsub(/<\/?[^>]*>/, "")
    records = source.split("\n")
    records.last[264,3].should == '2nd'
  end

end
