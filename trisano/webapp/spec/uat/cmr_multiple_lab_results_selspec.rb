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

# $dont_kill_browser = true

describe 'Adding multiple lab results to a CMR' do
  
  it "should allow adding new lab results to a new CMR" do
    @browser.open "/trisano/cmrs"
    click_nav_new_cmr(@browser).should be_true
    @browser.type "morbidity_event_active_patient__person_last_name", "Jones"
    @browser.type "morbidity_event_active_patient__person_first_name", "Indiana"

    click_core_tab(@browser, "Laboratory")
    @browser.click "link=Add a lab result"
    sleep(1)

    @browser.type "document.forms['new_morbidity_event'].elements['morbidity_event[new_lab_attributes][][name]'][0]", "Lab One"
    @browser.type "document.forms['new_morbidity_event'].elements['morbidity_event[new_lab_attributes][][test_type]'][0]", "Urinalysis"
    @browser.type "document.forms['new_morbidity_event'].elements['morbidity_event[new_lab_attributes][][lab_result_text]'][0]", "Positive"
    @browser.type "document.forms['new_morbidity_event'].elements['morbidity_event[new_lab_attributes][][interpretation]'][0]", "Healthy"

    @browser.type "document.forms['new_morbidity_event'].elements['morbidity_event[new_lab_attributes][][name]'][1]", "Lab Two"
    @browser.type "document.forms['new_morbidity_event'].elements['morbidity_event[new_lab_attributes][][test_type]'][1]", "Blood Test"
    @browser.type "document.forms['new_morbidity_event'].elements['morbidity_event[new_lab_attributes][][lab_result_text]'][1]", "Negative"
    @browser.type "document.forms['new_morbidity_event'].elements['morbidity_event[new_lab_attributes][][interpretation]'][1]", "Sickly"

    save_cmr(@browser).should be_true

    @browser.is_text_present('Jones').should be_true
    @browser.is_text_present('Lab One').should be_true
    @browser.is_text_present('Positive').should be_true
    @browser.is_text_present('Lab Two').should be_true
    @browser.is_text_present('Negative').should be_true
    @browser.is_text_present('Urinalysis').should be_true
    @browser.is_text_present('Blood Test').should be_true
    @browser.is_text_present('Healthy').should be_true
    @browser.is_text_present('Sickly').should be_true
  end

  it "should allow removing a lab result" do
    edit_cmr(@browser).should be_true
    @browser.click("link=Remove")
    save_cmr(@browser).should be_true
    @browser.is_text_present('Lab One').should_not be_true
  end

  it "should allow editing lab results" do
    edit_cmr(@browser).should be_true
    click_core_tab(@browser, "Laboratory")
    type_field_by_order(@browser, "morbidity_event_existing_lab_attributes", 0, "Uncertain")
    save_cmr(@browser).should be_true
    @browser.is_text_present('Uncertain').should be_true
  end
end
