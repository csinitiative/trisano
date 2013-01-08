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

describe 'Updating a task' do
  
  # $dont_kill_browser = true

  # Debt:
  #  * Test defaults (current user and Clinic).
  #  * Exercise user and location drop downs
  
  before(:all) do
    @cmr_last_name = get_random_word << " encounter-uat"
    @date = "March 10, 2009"
    @description = get_unique_name(3) << " encounter-uat"
    @new_date = "March 11, 2009"
    @new_description = get_unique_name(3) << " encounter-uat"
    @disease = get_random_disease
    @encounter_date_field_label = "Encounter date"
  end
  
  after(:all) do
    @cmr_last_name = nil
    @date = nil
    @description = nil
    @new_date = nil
    @new_description = nil
    @disease = nil
    @encounter_date_field_label = nil
  end

  it 'should not be possible to add an encounter on a new CMR' do
    @browser.open "/trisano/cmrs"
    click_nav_new_cmr(@browser)
    @browser.get_html_source.include?("No encounters").should be_true
    @browser.get_html_source.include?("Add an encounter").should be_false
    @browser.get_html_source.include?(@encounter_date_field_label).should be_false
  end
  
  it "should create a basic CMR" do
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @disease).should be_true
  end

  it 'should add an encounter' do
    edit_cmr(@browser)
    @browser.get_html_source.include?(@encounter_date_field_label).should be_true
    @browser.type('css=input[id$=participations_encounter_attributes_encounter_date]', @date)
    @browser.type('css=textarea[id$=participations_encounter_attributes_description]', @description)
    save_cmr(@browser)
    @browser.get_html_source.include?("2009-03-10").should be_true
    @browser.get_html_source.include?(@description).should be_true
  end

  it 'should edit the encounter' do
    edit_cmr(@browser)
    @browser.type('css=input[id$=participations_encounter_attributes_encounter_date]', @new_date)
    @browser.type('css=textarea[id$=participations_encounter_attributes_description]', @new_description)
    save_cmr(@browser)

    html_source = @browser.get_html_source
    html_source.include?("2009-03-10").should be_false
    html_source.include?(@description).should be_false

    html_source.include?("2009-03-11").should be_true
    html_source.include?(@new_description).should be_true
  end
  
  it 'should delete the encounter' do
    @browser.is_element_present("css=TD.struck-through").should be_false
    edit_cmr(@browser)
    # Assumes there is only one delete checkbox on the cmr
    @browser.click('css=input[id$=_destroy]')
    save_cmr(@browser)
    @browser.is_element_present("css=TD.struck-through").should be_true
  end
  
end
