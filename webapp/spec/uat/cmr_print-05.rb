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

require 'active_support'

require File.dirname(__FILE__) + '/spec_helper'

# $dont_kill_browser = true
$sleep_time = 5

describe 'Print CMR page' do
  before :all do
    @birth_date = Date.today.years_ago(43)
  end

  it 'should create a CMR with demographic info' do
    @browser.open "/trisano/cmrs"
    click_nav_new_cmr(@browser).should be_true
    add_demographic_info(@browser, {
        :last_name => "Lebowski",
        :first_name => "Jeffrey"
      })

    @browser.type('morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_middle_name', '`The Dude`')
    @browser.type('morbidity_event_address_attributes_street_number', '123')
    @browser.type('morbidity_event_address_attributes_street_name', 'Fake Street')
    @browser.type('morbidity_event_address_attributes_city', 'Venice')
    @browser.select('morbidity_event_address_attributes_state_id', 'label=California')
    @browser.select('morbidity_event_address_attributes_county_id', 'label=Out-of-state')
    @browser.type('morbidity_event_address_attributes_postal_code', '12345')
    @browser.type('morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_birth_date', @birth_date.strftime("%m/%d/%Y"))
    @browser.type('morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_approximate_age_no_birthday', '43')
    @browser.select('morbidity_event_interested_party_attributes_person_entity_attributes_telephones_attributes_0_entity_location_type_id', 'label=Work')
    @browser.type('morbidity_event_interested_party_attributes_person_entity_attributes_telephones_attributes_0_area_code', '555')
    @browser.type('morbidity_event_interested_party_attributes_person_entity_attributes_telephones_attributes_0_phone_number', '5551345')
    @browser.select('morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_birth_gender_id', 'label=Male')
    @browser.select('morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_ethnicity_id', 'label=Not Hispanic or Latino')
    @browser.add_selection('morbidity_event_interested_party_attributes_person_entity_attributes_race_ids', 'label=White')
    @browser.select('morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_primary_language_id', 'label=Hmong')
    save_and_continue(@browser).should be_true
  end
  
  it 'should edit the CMR to include clinical info' do
    click_core_tab(@browser, CLINICAL)
    @browser.select "morbidity_event_disease_event_attributes_disease_id", "label=Botulism, foodborne"
    @browser.type "morbidity_event_disease_event_attributes_disease_onset_date", "12/12/2002"
    @browser.type "morbidity_event_disease_event_attributes_date_diagnosed", "12/12/2003"

    add_diagnostic_facility(@browser, { :name => "American Fork Hospital" }, 1)
    add_diagnostic_facility(@browser, { :name => "Castleview Hospital" }, 2)
    add_diagnostic_facility(@browser, { :name => "Dixie Regional Medical Center" }, 3)
    add_diagnostic_facility(@browser, { :name => "Castleview Hospital" }, 4)

    add_hospital(@browser, { 
        :name => "Ashley Regional Medical Center",
        :admission_date => "1/1/1901",
        :discharge_date => "12/12/2003",
        :medical_record_number => "7"
      })

    @browser.select "morbidity_event_disease_event_attributes_died_id", "label=Yes"
    @browser.type "morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_date_of_death", "5/5/2009"
    @browser.select "morbidity_event_interested_party_attributes_risk_factor_attributes_pregnant_id", "label=Yes"
    @browser.type "morbidity_event_interested_party_attributes_risk_factor_attributes_pregnancy_due_date", "12/12/2009"
  
    add_treatment(@browser, {:treatment => "White Russian", :treatment_given => "label=Yes", :treatment_date => "1/17/1901"})

    add_clinician(@browser, {
        :last_name => "Mario",
        :first_name => "Mario",
        :middle_name => "A",
        :phone_type => "Home",
        :area_code => "555",
        :phone_number => "5551337",
        :extension => "555"
      })
  end
  
  it 'should edit the CMR to include lab info' do
    add_lab_result(@browser, {:lab_name => "Venture Complex",
        :lab_test_type => "Necromancy",
        :lab_result_text => "Zombies",
        :lab_interpretation => "Other",
        :lab_specimen_source => "Blood",
        :lab_collection_date => "12/12/2002",
        :lab_test_date => "12/13/2005",
        :sent_to_state => "Unknown"
      })

  end
  
  it 'should edit the CMR to include contacts' do
    click_core_tab(@browser, CONTACTS)
    add_contact(@browser, {:last_name => "Lina", :first_name => "Inverse"},1)
    add_contact(@browser, {:last_name => "Steve", :first_name => "Jobbs"},2)
  end
  
  it 'should edit the CMR to include encounters' do
    add_encounter(@browser, { :encounter_date => "March 10, 2009", :description => "Encounter desc" })
    save_cmr(@browser)
    @browser.click("link=Edit encounter event")
    @browser.wait_for_page_to_load($load_time)
    add_lab_result(@browser, { :lab_name => "Encounter lab name", :lab_test_type => "Encounter lab type", :lab_result_text => "Encounter lab result" })
    add_treatment(@browser, { :treatment_given => "Yes", :treatment => "Encounter treatment", :treatment_date => "March 11, 2009"})
    save_and_exit(@browser)
    @browser.click("link=Jeffrey Lebowski")
    @browser.wait_for_page_to_load($load_time)
  end
  
  it 'should edit the CMR to include EPI info' do
    click_core_tab(@browser, EPI)
    edit_cmr(@browser)
    @browser.select "morbidity_event_interested_party_attributes_risk_factor_attributes_food_handler_id", "label=No"
    @browser.select "morbidity_event_interested_party_attributes_risk_factor_attributes_healthcare_worker_id", "label=Yes"
    @browser.select "morbidity_event_interested_party_attributes_risk_factor_attributes_group_living_id", "label=No"
    @browser.select "morbidity_event_interested_party_attributes_risk_factor_attributes_day_care_association_id", "label=Yes"
    @browser.type "morbidity_event_interested_party_attributes_risk_factor_attributes_occupation", "Unemployed"
    @browser.type "morbidity_event_interested_party_attributes_risk_factor_attributes_risk_factors", "Nope"
    @browser.type "morbidity_event_interested_party_attributes_risk_factor_attributes_risk_factors_notes", "Whatever, Man"
    @browser.select "morbidity_event_imported_from_id", "label=Unknown"
  end
  
  it 'should edit the CMR to include reporting info' do
    add_reporting_info(@browser, {
        :name => "why",
        :area_code => "555",
        :extension => "555",
        :phone_number => "5550150",
        :first_name => "what",
        :last_name => "how",
        :clinician_date => "12/12/2004",
        :PH_date => "12/12/2005"
      })
  end
  
  it 'should create a note' do
    click_core_tab(@browser, NOTES)
    add_note(@browser, "I'm the operator with my pocket calculator (beep boop)")
  end
  
  it 'should edit the CMR to include admin info' do
    click_core_tab(@browser, ADMIN)
    @browser.select "morbidity_event_lhd_case_status_id", "label=Confirmed"
    @browser.select "morbidity_event_state_case_status_id", "label=Not a Case"
    @browser.select "morbidity_event_outbreak_associated_id", "label=Yes"
    @browser.type "morbidity_event_outbreak_name", "POCKET MONSTERS"
    @browser.select "morbidity_event_jurisdiction_attributes_secondary_entity_id", "label=Central Utah Public Health Department"
    @browser.type "morbidity_event_investigation_started_date", "12/3/2003"
    @browser.type "morbidity_event_investigation_completed_LHD_date", "12/7/2007"
    @browser.type "morbidity_event_event_name", "Y HELO THAR"
    @browser.type "morbidity_event_review_completed_by_state_date", "12/5/1963"
    @browser.type "morbidity_event_acuity", "1"
    save_cmr(@browser).should be_true
  end
  
  it 'should correctly display the information to the print page, report only' do
    print_cmr(@browser).should be_true
    @browser.is_text_present('Confidential Case Report').should be_true
    @browser.is_text_present('Lebowski').should be_true
    @browser.is_text_present('Botulism, foodborne').should be_true
    @browser.is_text_present('Lebowski').should be_true
    @browser.is_text_present('Jeffrey').should be_true
    @browser.is_text_present('`The Dude`').should be_true
    @browser.is_text_present('123').should be_true
    @browser.is_text_present('Fake Street').should be_true
    @browser.is_text_present('Venice').should be_true
    @browser.is_text_present('California').should be_true
    @browser.is_text_present('Out-of-state').should be_true
    @browser.is_text_present('12345').should be_true
    @browser.is_text_present(@birth_date.strftime("%Y-%m-%d")).should be_true
    @browser.is_text_present('43').should be_true
    @browser.is_text_present('(555) 555-1345').should be_true
    @browser.is_text_present('Male').should be_true
    @browser.is_text_present('Hmong').should be_true
    @browser.is_text_present('Not Hispanic or Latino').should be_true
  
    @browser.is_text_present('2009-03-10').should be_true
    @browser.is_text_present('Encounter desc').should be_true
    @browser.is_text_present('Encounter lab name').should be_true
    @browser.is_text_present('Encounter lab type').should be_true
    @browser.is_text_present('Encounter treatment').should be_true
    @browser.is_text_present('2009-03-11').should be_true

    @browser.is_text_present('2002-12-12').should be_true
    @browser.is_text_present('2003-12-12').should be_true
    @browser.is_text_present('Yes').should be_true
    @browser.is_text_present('2009-05-05').should be_true
    @browser.is_text_present('2009-12-12').should be_true
    @browser.is_text_present('Unknown').should be_true
    @browser.is_text_present('American Fork Hospital').should be_true
    @browser.is_text_present('Castleview Hospital').should be_true
    @browser.is_text_present('Dixie Regional Medical Center').should be_true
    @browser.is_text_present('Ashley Regional Medical Center').should be_true
    @browser.is_text_present('1901-01-01').should be_true
    @browser.is_text_present('2003-12-12').should be_true
    @browser.is_text_present('7').should be_true
    @browser.is_text_present('No').should be_true
    @browser.is_text_present('White Russian').should be_true
    @browser.is_text_present('Mario').should be_true
    @browser.is_text_present('Venture Complex').should be_true
    @browser.is_text_present('Necromancy').should be_true
    @browser.is_text_present('Blood').should be_true
    @browser.is_text_present('Zombies').should be_true
    @browser.is_text_present('2005-12-13').should be_true
    @browser.is_text_present('Lina').should be_true
    @browser.is_text_present('Inverse').should be_true
    @browser.is_text_present('Steve').should be_true
    @browser.is_text_present('Jobbs').should be_true
    @browser.is_text_present('Unemployed').should be_true
    @browser.is_text_present('Whatever, Man').should be_true
    @browser.is_text_present('what').should be_true
    #    @browser.is_text_present('how').should be_true
    @browser.is_text_present('why').should be_true
    @browser.is_text_present('5550150').should be_true
    @browser.is_text_present('2004-12-12').should be_true
    @browser.is_text_present('2005-12-12').should be_true
    @browser.is_text_present('2005').should be_true
    @browser.is_text_present('POCKET MONSTERS').should be_true
    @browser.is_text_present('Y HELO THAR').should be_true
    @browser.is_text_present('New').should be_true
    @browser.is_text_present('2003-12-03').should be_true
    @browser.is_text_present('1963-12-05').should be_true
    @browser.is_text_present('2007-12-07').should be_true
    @browser.is_text_present('Extra Keen').should be_true
    @browser.is_text_present('Notes').should be_false
    @browser.is_text_present("I'm the operator with my pocket calculator (beep boop)").should be_false
    @browser.close()
    @browser.select_window ''
  end
  
  it 'should display notes on With Notes' do
    @browser.print_cmr(@browser, 1)
    @browser.is_text_present('Notes').should be_true
    @browser.is_text_present("I'm the operator with my pocket calculator (beep boop)").should be_true
    @browser.close()
    @browser.select_window 'null'
  end

end
