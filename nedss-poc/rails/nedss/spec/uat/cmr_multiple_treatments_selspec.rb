require File.dirname(__FILE__) + '/spec_helper'

describe 'Adding multiple treatments to a CMR' do
  
  it "should allow a single treatment to be saved with a new CMR" do
    @browser.open "/nedss/cmrs"
    @browser.click "link=New CMR"
    @browser.wait_for_page_to_load($load_time)
    @browser.type "event_active_patient__active_primary_entity__person_last_name", "Smith"
    @browser.type "event_active_patient__active_primary_entity__person_first_name", "Jersey"
    click_core_tab(@browser, "Clinical")
    @browser.select "event_active_patient__participations_treatment_treatment_given_yn_id", "label=Yes"
    @browser.type "event_active_patient__participations_treatment_treatment", "Leeches"
    @browser.click "event_submit"
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Leeches').should be_true
  end

  it "should allow editing a treatment from the CMR's show mode" do
    click_core_tab(@browser, "Clinical")
    @browser.click "link=Edit treatment"
    sleep(3)
    # @browser.wait_for_element_present("treatment_form")
    @browser.type "participations_treatment_treatment", "Blood Letting"
    @browser.click "treatment-save-button"
    sleep(3)
    # @browser.wait_for_element_not_present("treatment_form")
    @browser.is_text_present('Blood Letting').should be_true
  end

  it "should allow editing a treatment from the CMR's edit mode" do
    @browser.click "edit_cmr_link"
    @browser.wait_for_page_to_load($load_time)
    click_core_tab(@browser, "Clinical")
    @browser.click "link=Edit treatment"
    sleep(3)
    # @browser.wait_for_element_present("treatment_form")
    @browser.type "participations_treatment_treatment", "Toad saliva"
    @browser.click "treatment-save-button"
    sleep(3)
    # @browser.wait_for_element_not_present("treatment_form")
    @browser.is_text_present('Toad saliva').should be_true
  end

  it "should allow adding a treatment from the CMR's edit mode" do
    @browser.click "link=New Treatment"
    sleep(3)
    # @browser.wait_for_element_present("treatment_form")
    @browser.select "participations_treatment_treatment_given_yn_id", "label=No"
    @browser.type "participations_treatment_treatment", "Mercury"
    @browser.click "treatment-save-button"
    sleep(3)
    # @browser.wait_for_element_not_present("treatment_form")
    @browser.is_text_present('Toad saliva').should be_true
    @browser.is_text_present('Mercury').should be_true
  end
end
