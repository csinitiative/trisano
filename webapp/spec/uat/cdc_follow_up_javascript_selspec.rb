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

describe 'CDC export follow ups' do

  # $dont_kill_browser = true

  before :all do
    @browser.open "/trisano/cmrs"
    @field_name = "Gestation #{get_unique_name(1)}"
  end

  it 'should add mumps form and core cdc follow up to cdc output' do
    click_nav_forms(@browser).should be_true
    @browser.click("//input[@value='Create New Form']")
    @browser.wait_for_page_to_load
    @browser.type("//input[@id='form_name']", "mumpy #{get_unique_name(1)}")
    @browser.type("//input[@id='form_short_name']", "mumpy #{get_unique_name(1)}")
    @browser.select("//select[@id='form_event_type']", "Morbidity Event")
    @browser.check("//input[@id='Mumps']")
    @browser.click("//input[@value='Create']")
    @browser.wait_for_page_to_load
    @browser.click("//a[text()='Builder']")
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
    @browser.type("//input[@id='question_element_question_attributes_question_text']", @field_name)
    @browser.type("//input[@id='question_element_question_attributes_short_name']", @field_name)
    @browser.select("//select[@id='question_element_export_column_id']", "Number of weeks gestation (or trimester) at onset")
    @browser.click("//input[@value='Create']")
    wait_for_element_present("//i[text()='Blank']")
    @browser.click("//input[@value='Publish']")
    @browser.wait_for_page_to_load

    @browser.open "/trisano/cmrs/new"
    @browser.wait_for_page_to_load

    add_demographic_info(@browser, { :last_name => "#{get_unique_name(1)} mumpy cdc" })
    add_clinical_info(@browser, { :disease => "Mumps" })
    first_reported_to_ph_date @browser, Date.today
    add_admin_info(@browser, { :state_case_status => "Confirmed" })
    save_and_continue(@browser)
    add_clinical_info(@browser, { :pregnant => "Yes" })
    wait_for_element_present("//label[text()='#{@field_name}']")
    @browser.select("//label[text()='#{@field_name}']/../select", "Second trimester")
    save_cmr(@browser)

    # check the cdc output
    @browser.open "/trisano/cdc_events/current_week.txt"
    @browser.wait_for_page_to_load($load_time)
    source = @browser.get_html_source.gsub(/<\/?[^>]*>/, "")
    records = source.split("\n")
    records[1][264,3].should == '2nd'
  end

end
