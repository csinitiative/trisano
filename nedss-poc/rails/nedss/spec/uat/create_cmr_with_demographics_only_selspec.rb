require File.dirname(__FILE__) + '/spec_helper'

describe 'Sytem functionality for setting the record ID of a CMR' do

  it 'should create a person with all the demographics information' do
    @browser.open "/nedss/cmrs"
    @browser.click('link=New CMR')
    @browser.wait_for_page_to_load($load_time)
    @browser.type('event_active_patient__active_primary_entity__person_last_name', 'Christiansen')
    @browser.type('event_active_patient__active_primary_entity__person_first_name', 'David')
    @browser.type('event_active_patient__active_primary_entity__address_street_number', '123')
    @browser.type('event_active_patient__active_primary_entity__address_street_name', 'My Street')
    @browser.type('event_active_patient__active_primary_entity__address_city', 'Hometown')
    @browser.select('event_active_patient__active_primary_entity__address_state_id', 'label=Texas')
    @browser.select('event_active_patient__active_primary_entity__address_county_id', 'label=Out-of-state')
    @browser.type('event_active_patient__active_primary_entity__address_postal_code', '46060')
    @browser.type('event_active_patient__active_primary_entity__person_birth_date', '4/1/1989')
    @browser.type('event_active_patient__active_primary_entity__person_approximate_age_no_birthday', '34')
    @browser.type('event_active_patient__active_primary_entity__telephone_area_code', '333')
    @browser.type('event_active_patient__active_primary_entity__telephone_phone_number', '5551212')
    @browser.select('event_active_patient__active_primary_entity__person_birth_gender_id', 'label=Male')
    @browser.select('event_active_patient__active_primary_entity__person_ethnicity_id', 'label=Not Hispanic or Latino')
    @browser.add_selection('event_active_patient__active_primary_entity_race_ids', 'label=White')
    @browser.select('event_active_patient__active_primary_entity__person_primary_language_id', 'label=Hmong')
    @browser.click('event_submit')
    @browser.wait_for_page_to_load($load_time)
    puts('Attempting to submit')
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('CMR was successfully created.').should be_true
    
    @browser.is_text_present('Christiansen').should be_true
    @browser.is_text_present('David').should be_true
    @browser.is_text_present('123 My Street, Hometown, Texas, 46060 : Out-of-state county').should be_true
    @browser.is_text_present('1989-04-01').should be_true
    pending("A user should not be allowed to enter an age value if it is going to be calculated from birth date") do
      @browser.is_text_present('34').should be_true
    end
    @browser.is_text_present('(333) 555-1234').should be_true
    @browser.is_text_present('Male').should be_true
    @browser.is_text_present('46060').should be_true
    @browser.is_text_present('Hmong').should be_true
    @browser.is_text_present('White').should be_true
    @browser.is_text_present('Not Hispanic or Latino').should be_true
  end
end
