require File.dirname(__FILE__) + '/spec_helper'

describe 'Adding multiple diagnosing health facilities to a CMR' do
  
  # $dont_kill_browser = true
  
  it "should allow a single diagnosing health facility to be saved with a new CMR" do
    @browser.open "/nedss/cmrs"
    click_nav_new_cmr(@browser).should be_true
    @browser.type "event_active_patient__active_primary_entity__person_last_name", "Diagnosing-HF"
    @browser.type "event_active_patient__active_primary_entity__person_first_name", "Johnny"
    click_core_tab(@browser, "Clinical")
    @browser.select "event_new_hospital_attributes__secondary_entity_id", "label=Ogden Regional Medical Center"
    save_cmr(@browser).should be_true
    @browser.is_text_present('Diagnosing-HF').should be_true
    @browser.is_text_present('Ogden Regional Medical Center').should be_true
  end

  it "should display a diagnosing health facility from the CMR's show mode" do
    click_core_tab(@browser, "Clinical")
    @browser.is_text_present('Ogden Regional Medical Center').should be_true
  end

  it "should allow editing a diagnosing health facility from the CMR's edit mode" do
    edit_cmr(@browser).should be_true
    click_core_tab(@browser, "Clinical")
    #@browser.select "event_existing_diagnostic_attributes_28_secondary_entity_id", "label=Delta Community Medical Center"
    #save_cmr(@browser).should be_true
    pending @browser.is_text_present('Delta Community Medical Center').should be_true
  end

  it "should allow adding a diagnosing health facility from the CMR's edit mode" do
    @browser.click("link=Add a diagnosing facility")
    sleep(3)
    @browser.select "event_new_diagnostic_attributes__secondary_entity_id", "label=Gunnison Valley Hospital"
    save_cmr(@browser).should be_true
    @browser.is_text_present('Gunnison Valley Hospital').should be_true
  end 
  
end
