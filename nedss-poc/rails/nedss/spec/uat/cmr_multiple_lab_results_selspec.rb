require File.dirname(__FILE__) + '/spec_helper'

describe 'Adding multiple lab results to a CMR' do
  
  it "should allow a single lab results to be saved with a new CMR" do
    @browser.open "/nedss/cmrs"
    @browser.click "link=New CMR"
    @browser.wait_for_page_to_load($load_time)
    @browser.type "event_active_patient__active_primary_entity__person_last_name", "Jones"
    @browser.type "event_active_patient__active_primary_entity__person_first_name", "Indiana"
    click_core_tab(@browser, "Laboratory")
    @browser.type "event_lab_result_lab_result_text", "Positive"
    @browser.select "event_lab_result_specimen_source_id", "label=Abcess"
    @browser.type "event_lab_result_collection_date", "June 3, 2008"
    @browser.type "event_lab_result_lab_test_date", "June 4, 2008"
    @browser.select "event_lab_result_tested_at_uphl_yn_id", "label=Yes"
    @browser.click "event_submit"
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('CMR was successfully created.').should be_true
    @browser.is_text_present('Jones').should be_true
    @browser.is_text_present('Positive').should be_true
    @browser.is_text_present('2008-06-03').should be_true
    @browser.is_text_present('2008-06-04').should be_true
    @browser.is_text_present('Yes').should be_true
  end

  it "should allow editing a lab result from the CMR's show mode" do
    click_core_tab(@browser, "Laboratory")
    @browser.click "link=Edit lab result"
    sleep(3)
    # @browser.wait_for_element_present("lab_info_form")
    @browser.select "lab_result_specimen_source_id", "label=Animal head"
    @browser.click "save-button"
    sleep(3)
    # @browser.wait_for_element_not_present("lab_info_form")
    @browser.is_text_present('Animal head').should be_true
  end

  it "should allow editing a lab result from the CMR's edit mode" do
    @browser.click "edit_cmr_link"
    @browser.wait_for_page_to_load($load_time)
    click_core_tab(@browser, "Laboratory")
    @browser.click "link=Edit lab result"
    sleep(3)
    # @browser.wait_for_element_present("lab_info_form")
    @browser.select "lab_result_specimen_source_id", "label=Blood"
    @browser.click "save-button"
    sleep(3)
    # @browser.wait_for_element_not_present("lab_info_form")
    @browser.is_text_present('Blood').should be_true
  end

  it "should allow adding a lab result from the CMR's edit mode" do
    @browser.click "link=New Lab Result"
    sleep(3)
    # @browser.wait_for_element_present("lab_info_form")
    @browser.type "lab_result_lab_result_text", "Negative"
    @browser.select "lab_result_specimen_source_id", "label=Brain Tissue"
    @browser.click "save-button"
    sleep(3)
    # @browser.wait_for_element_not_present("lab_info_form")
    @browser.is_text_present('Positive').should be_true
    @browser.is_text_present('Negative').should be_true
    @browser.is_text_present('Blood').should be_true
    @browser.is_text_present('Brain Tissue').should be_true
  end
end
