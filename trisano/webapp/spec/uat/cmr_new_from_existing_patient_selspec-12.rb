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

require 'date'
require File.dirname(__FILE__) + '/spec_helper'

# $dont_kill_browser = true

describe 'Creating a new cmr from an existing patient' do

  before(:all) do
    @browser.open '/trisano/cmrs'
    @last_name = get_random_word + 'from_existing'
    @disease_name = get_random_disease
    @jurisdiction = get_random_jurisdiction
    @birth_date = 'March 9, 1980'
    @calculated_values = {}
  end

  after(:all) do
    @last_name = nil
    @disease_name = nil
    @jurisdiction = nil
  end

  it 'should start with a simple cmr' do
    create_basic_investigatable_cmr(@browser, @last_name, @disease_name, @jurisdiction).should be_true
    @calculated_values[:record_number] = get_record_number(@browser)
    @calculated_values[:record_number].should =~ /^2008/
  end

  it 'should create a new cmr based w/ the same patient' do
    @browser.click('link=Create New Patient Event')
    @browser.wait_for_page_to_load
    @browser.is_text_present('CMR was successfully created.')
  end

  it 'should be the same patient name' do
    @browser.get_value('id=morbidity_event_active_patient__person_last_name').should == @last_name
  end

  it 'should be the same street address' do
    @browser.get_value('id=morbidity_event_active_patient__address_street_number').should == '22'
    @browser.get_value('id=morbidity_event_active_patient__address_street_name').should == 'Happy St.'
  end

  it 'should not have a disease in the new cmr' do
    @browser.get_value('id=morbidity_event_disease_disease_id').should == ''
  end

  it 'should be able to change patient information' do
    @browser.type('morbidity_event_active_patient__person_birth_date', @birth_date)
    save_cmr(@browser).should be_true
  end

  it 'should show patient information changes in original cmr' do
    @browser.click('link=SEARCH')
    @browser.wait_for_page_to_load
    @browser.click('link=Event Search')
    @browser.wait_for_page_to_load
    @browser.type('name', @last_name)
    @browser.click("//input[@type='submit']")
    @browser.wait_for_page_to_load
    @browser.click("link=#{@calculated_values[:record_number]}")
    @browser.wait_for_page_to_load
    @browser.click('link=Edit')
    @browser.wait_for_page_to_load
    bd = Date.parse(@birth_date).strftime('%B %d, %Y')
    @browser.get_value('morbidity_event_active_patient__person_birth_date').should == bd
  end
    

end
