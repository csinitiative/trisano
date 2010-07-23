# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

describe 'Encounter event treatments' do
  
  # $dont_kill_browser = true
  
  before(:all) do
    @cmr_last_name = get_random_word << " en-t-uat"
    @disease = get_random_disease
    @encounter_date = "March 10, 2009"
    @encounter_description = get_unique_name(3) << " en-t-uat"
    @treatment_name = get_unique_name(1) << " en-t-uat"
    @treatment_date = "March 11, 2009"
  end
  
  after(:all) do
    @cmr_last_name = nil
    @disease = nil
    @encounter_date = nil
    @encounter_description = nil
    @treatment_name = nil
    @treatment_date = nil
  end

  it 'should create a basic investigatable CMR' do
    @browser.open "/trisano"
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @disease).should be_true
  end

  it 'should add an encounter' do
    edit_cmr(@browser)
    add_encounter(@browser, { :encounter_date => @encounter_date, :description => @encounter_description })
    save_cmr(@browser)
    @browser.is_text_present("2009-03-10").should be_true
    @browser.is_text_present(@encounter_description).should be_true
  end

  it 'should add a treatment to the encounter' do
    @browser.click("link=Edit Encounter")
    @browser.wait_for_page_to_load($load_time)
    add_treatment(@browser, { :treatment_given => "Yes", :treatment_name => @treatment_name, :treatment_date => @treatment_date })
    save_and_exit(@browser)
    @browser.is_text_present(@treatment_name).should be_true
    @browser.is_text_present("2009-03-11").should be_true
  end
  
  it 'should show the encounter event treatments on the morbidity event' do
    @browser.click("link=#{@cmr_last_name}")
    @browser.wait_for_page_to_load($load_time)
    @browser.get_html_source.include?(@treatment_name).should be_true
    @browser.get_html_source.include?("2009-03-10").should be_true
  end

end
