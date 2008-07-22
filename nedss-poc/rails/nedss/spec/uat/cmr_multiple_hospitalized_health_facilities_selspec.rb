require File.dirname(__FILE__) + '/spec_helper'

describe 'Adding multiple hospitalized health facilities to a CMR' do
  
  # $dont_kill_browser = true
  
  it "should allow a single hospitalized health facility to be saved with a new CMR" do
    @browser.open "/nedss/cmrs"
    click_nav_new_cmr(@browser).should be_true
    @browser.type "event_active_patient__active_primary_entity__person_last_name", "Hospitalized-HF"
    @browser.type "event_active_patient__active_primary_entity__person_first_name", "Johnny"
    click_core_tab(@browser, "Clinical")
    @browser.select "event_new_hospital_attributes__secondary_entity_id", "label=Garfield Memorial Hospital"
    @browser.type "event_new_hospital_attributes__admission_date", "June 24, 2008"
    @browser.type "event_new_hospital_attributes__discharge_date", "June 25, 2008"
    save_cmr(@browser).should be_true
    @browser.is_text_present('Hospitalized-HF').should be_true
    @browser.is_text_present('Garfield Memorial Hospital').should be_true
    @browser.is_text_present('2008-06-24').should be_true
    @browser.is_text_present('2008-06-25').should be_true
  end

  it "should display a hospitalized health facility from the CMR's show mode" do
    click_core_tab(@browser, "Clinical")
    @browser.is_text_present('Garfield Memorial Hospital').should be_true
  end

  it "should allow editing a hospitalized health facility from the CMR's edit mode" do
    edit_cmr(@browser).should be_true
    click_core_tab(@browser, "Clinical")
    #@browser.select "event_existing_hospital_attributes_67_secondary_entity_id", "label=Garfield Memorial Hospital"
    #save_cmr(@browser).should be_true
    pending @browser.is_text_present('Garfield Memorial Hospital').should be_true
  end

  it "should allow adding a hospitalized health facility from the CMR's edit mode" do
    #This can be uncommented when the previous test works... 
    #edit_cmr(@browser).should be_true 
    @browser.click("link=Add a hospital")
    sleep(3)
    @browser.select "event_new_hospital_attributes__secondary_entity_id", "label=Gunnison Valley Hospital"
    save_cmr(@browser).should be_true
    @browser.is_text_present('Gunnison Valley Hospital').should be_true
  end 
end
