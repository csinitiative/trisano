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
require 'active_support'

describe 'Adding multiple treatments to a CMR' do
  
  it "should allow a single treatment to be saved with a new CMR" do
    display_date = 10.days.ago.strftime('%B %d, %Y')
    @browser.open "/trisano/cmrs"
    click_nav_new_cmr(@browser).should be_true
    @browser.type "morbidity_event_active_patient__active_primary_entity__person_last_name", "Smith"
    @browser.type "morbidity_event_active_patient__active_primary_entity__person_first_name", "Jersey"
    click_core_tab(@browser, "Clinical")
    @browser.select "morbidity_event_active_patient__participations_treatment_treatment_given_yn_id", "label=Yes"
    @browser.type "morbidity_event_active_patient__participations_treatment_treatment", "Leeches"
    @browser.type "morbidity_event_active_patient__participations_treatment_treatment_date", display_date
    save_cmr(@browser).should be_true
    @browser.is_text_present('Treatment Date').should be_true
    @browser.is_text_present('Leeches').should be_true
    @browser.is_text_present(display_date).should be_true
  end

  it "should allow editing a treatment from the CMR's show mode" do
    display_date = 8.days.ago.strftime('%B %d, %Y')
    click_core_tab(@browser, "Clinical")
    @browser.click "link=Edit treatment"
    sleep(3)
    # @browser.wait_for_element_present("treatment_form")
    @browser.type "participations_treatment_treatment", "Blood Letting"
    @browser.type "participations_treatment_treatment_date", display_date
    @browser.click "treatment-save-button"
    sleep(3)
    # @browser.wait_for_element_not_present("treatment_form")
    @browser.is_text_present('Blood Letting').should be_true
    @browser.is_text_present(display_date).should be_true
  end

  it "should allow editing a treatment from the CMR's edit mode" do
    display_date = 11.days.ago.strftime('%B %d, %Y')
    edit_cmr(@browser).should be_true
    click_core_tab(@browser, "Clinical")
    @browser.click "link=Edit treatment"
    sleep(3)
    # @browser.wait_for_element_present("treatment_form")
    @browser.type "participations_treatment_treatment", "Toad saliva"
    @browser.type 'participations_treatment_treatment_date', display_date
    @browser.click "treatment-save-button"
    sleep(3)
    # @browser.wait_for_element_not_present("treatment_form")
    @browser.is_text_present('Toad saliva').should be_true
    @browser.is_text_present(display_date).should be_true
  end

  it "should allow adding a treatment from the CMR's edit mode" do
    display_date = 7.days.ago.strftime('%B %d, %Y')
    @browser.click "link=New Treatment"
    sleep(3)
    # @browser.wait_for_element_present("treatment_form")
    @browser.select "participations_treatment_treatment_given_yn_id", "label=No"
    @browser.type "participations_treatment_treatment", "Mercury"
    @browser.type 'participations_treatment_treatment_date', display_date
    @browser.click "treatment-save-button"
    sleep(3)
    # @browser.wait_for_element_not_present("treatment_form")
    @browser.is_text_present('Toad saliva').should be_true
    @browser.is_text_present('Mercury').should be_true
    @browser.is_text_present(display_date).should be_true
  end
end
