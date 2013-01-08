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

require 'active_support'

require File.dirname(__FILE__) + '/spec_helper'
describe 'User functionality for creating and saving CMRs' do

$dont_kill_browser = true

  before(:all) do
    @last_name = get_unique_name(1)
    @browser.open "/trisano/cmrs"
  end

  it 'should save a CMR with just a last name' do
    click_nav_new_cmr(@browser).should be_true
    @browser.type('morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_last_name', @last_name)
    @browser.type "//input[@id='morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_birth_date']", Date.today.years_ago(13).strftime("%m/%d/%Y")
    first_reported_to_ph_date @browser, Date.today
    save_cmr(@browser).should be_true
     @browser.get_html_source.include?(@last_name).should be_true
     @browser.get_html_source.include?(Date.today.years_ago(13).strftime("%Y-%m-%d"))
  end

  it 'should save the contact information' do
    edit_cmr(@browser).should be_true
    click_core_tab(@browser, "Contacts")
    @browser.click "link=Add a contact"
    sleep(1)
    @browser.type "//div[@class='contact'][1]//input[contains(@id, 'last_name')]", "Costello"
    save_cmr(@browser).should be_true
     @browser.get_html_source.include?('Costello').should be_true
  end

  it 'should save the street name' do
    edit_cmr(@browser).should be_true
    click_core_tab(@browser, "Demographics")
    @browser.type('morbidity_event_address_attributes_street_name', 'Junglewood Court')

    save_cmr(@browser).should be_true
  end

  it 'should save the phone number' do
    edit_cmr(@browser).should be_true
    @browser.select "//div[@id='demographic_tab']//div[@id='telephones']//select", 'label=Work'
    @browser.type "//div[@id='demographic_tab']//div[@id='telephones']//input[contains(@id, 'area_code')]",    '801'
    @browser.type "//div[@id='demographic_tab']//div[@id='telephones']//input[contains(@id, 'phone_number')]", '5811234'
    save_cmr(@browser).should be_true
  end

  it 'should save the disease info' do
    edit_cmr(@browser).should be_true
    click_core_tab(@browser, "Clinical")
    @browser.select 'morbidity_event_disease_event_attributes_disease_id', 'label=AIDS'
    save_cmr(@browser).should be_true
  end

  it 'should save the reporting info' do
    pending 'Reporting tab stuff still needs repaired'
    edit_cmr(@browser).should be_true
    click_core_tab(@browser, "Reporting")
    @browser.click("//a[@id='add_reporting_agency_link']")
    sleep(1)
    @browser.type("//input[contains(@name, '[active_reporting_agency][name]')]", 'Happy Jacks Health Store')
    save_cmr(@browser).should be_true
  end

  it 'should save administrative info' do
    edit_cmr(@browser).should be_true
    click_core_tab(@browser, "Administrative")
    @browser.type 'morbidity_event_event_name', 'Test Event'
    @browser.type 'morbidity_event_acuity', '1'
    save_cmr(@browser).should be_true
  end

  it 'should still have all the data present' do
    html_source = @browser.get_html_source
    html_source.include?(@last_name).should be_true
    html_source.include?('Junglewood Court').should be_true
    html_source.include?('(801) 581-1234').should be_true
    html_source.include?('AIDS').should be_true
    @browser.is_element_present("//div[@id='administrative_tab']//label[text()='Acuity']").should be_true
    html_source.include?('Costello').should be_true
  end
end
