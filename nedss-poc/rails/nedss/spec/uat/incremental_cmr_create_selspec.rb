require File.dirname(__FILE__) + '/spec_helper'
  
  describe 'User functionality for creating and saving CMRs' do

  it 'should allow the user to save CMR incrementally without losing data' do
    @browser.open "/nedss/cmrs"
    @browser.click('link=New CMR')
    @browser.wait_for_page_to_load($load_time)
    @browser.type('event_active_patient__active_primary_entity__person_last_name', 'Jorgenson')
    @browser.click('event_submit')
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Jorgenson').should be_true
    @browser.is_text_present('CMR was successfully created.').should be_true
  
    @browser.click('link=Edit')
    @browser.wait_for_page_to_load($load_time)
    @browser.type('event_active_patient__active_primary_entity__address_street_name', 'Junglewood Court')
    @browser.click('event_submit')
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('CMR was successfully updated.').should be_true

    @browser.click 'link=Edit'
    @browser.wait_for_page_to_load($load_time)
    @browser.type 'event_active_patient__active_primary_entity__telephone_area_code', '801'
    @browser.type 'event_active_patient__active_primary_entity__telephone_phone_number', '581'
    @browser.type 'event_active_patient__active_primary_entity__telephone_extension', '1234'
    @browser.type 'event_active_patient__active_primary_entity__telephone_phone_number', '5811234'
    @browser.click 'event_submit'
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('CMR was successfully updated.').should be_true

    @browser.click 'link=Edit'
    @browser.wait_for_page_to_load($load_time)
    @browser.click '//li[4]/a/em'
    @browser.click '//li[2]/a/em'
    @browser.select 'event_disease_disease_id', 'label=AIDS'
    @browser.click 'event_submit'
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('CMR was successfully updated.').should be_true

    @browser.click 'link=Edit'
    @browser.wait_for_page_to_load($load_time)
    @browser.click '//li[3]/a/em'
    @browser.select 'event_lab_result_specimen_source_id', 'label=Animal head'
    @browser.click 'event_submit'
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('CMR was successfully updated.').should be_true

    @browser.click 'link=Edit'
    @browser.wait_for_page_to_load($load_time)
    @browser.click '//li[3]/a/em'
    @browser.click '//li[2]/a/em'
    @browser.select 'event_active_patient__participations_treatment_treatment_given_yn_id', 'label=Yes'
    @browser.click 'event_submit'
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('CMR was successfully updated.').should be_true

    @browser.click 'link=Edit'
    @browser.wait_for_page_to_load($load_time)
    @browser.click '//li[5]/a/em'
    @browser.type 'model_auto_completer_tf', 'Happy Jacks Health Store'
    @browser.click 'event_submit'
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('CMR was successfully updated.').should be_true

    @browser.click 'link=Edit'
    @browser.wait_for_page_to_load($load_time)
    @browser.click '//li[6]/a/em'
    @browser.select 'event_active_jurisdiction_secondary_entity_id', 'label=Salt Lake Valley Health Department'
    @browser.click 'event_submit'
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('CMR was successfully updated.').should be_true

    @browser.click 'link=Edit'
    @browser.wait_for_page_to_load($load_time)
    @browser.click '//li[2]/a/em'
    @browser.select 'event_active_hospital_secondary_entity_id', 'label=Brigham City Community Hospital'
    @browser.click 'event_submit'
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('CMR was successfully updated.').should be_true

    @browser.click 'link=Edit'
    @browser.wait_for_page_to_load($load_time)
    @browser.click '//li[2]/a/em'
    @browser.select 'event_disease_hospitalized_id', 'label=Yes'
    @browser.type 'event_active_hospital__hospitals_participation_admission_date', '4/1/2008'
    @browser.type 'event_active_hospital__hospitals_participation_discharge_date', '4/25/2008'
    @browser.click 'event_submit'
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('CMR was successfully updated.').should be_true

    @browser.is_text_present('Jorgenson').should be_true
    @browser.is_text_present('Junglewood Court').should be_true
    @browser.is_text_present('(801) 581-1234 Ext. 1234').should be_true
    
    @browser.click '//li[2]/a/em'
    @browser.is_text_present('AIDS').should be_true
    @browser.is_text_present('Yes').should be_true
    @browser.is_text_present('Brigham City Community Hospital').should be_true
    @browser.is_text_present('2008-04-01').should be_true
    @browser.is_text_present('2008-04-25').should be_true
    
    @browser.click '//li[3]/a/em'
    @browser.is_text_present('Animal head').should be_true
    
    @browser.click '//li[6]/a/em'
    @browser.is_text_present('Salt Lake Valley Health Department').should be_true
  end
end
