require File.dirname(__FILE__) + '/spec_helper'

# $dont_kill_browser = true

describe 'Adding multiple lab results to a CMR' do
  
  it "should allow adding new lab results to a new CMR" do
    @browser.open "/nedss/cmrs"
    click_nav_new_cmr(@browser)
    @browser.type "event_active_patient__active_primary_entity__person_last_name", "Jones"
    @browser.type "event_active_patient__active_primary_entity__person_first_name", "Indiana"

    click_core_tab(@browser, "Laboratory")
    @browser.click "link=Add a lab result"
    sleep(1)

    @browser.type "document.forms['new_event'].elements['event[new_lab_attributes][][name]'][0]", "Lab One"
    @browser.type "document.forms['new_event'].elements['event[new_lab_attributes][][lab_result_text]'][0]", "Positive"

    @browser.type "document.forms['new_event'].elements['event[new_lab_attributes][][name]'][1]", "Lab Two"
    @browser.type "document.forms['new_event'].elements['event[new_lab_attributes][][lab_result_text]'][1]", "Negative"

    save_cmr(@browser)

    @browser.is_text_present('CMR was successfully created.').should be_true
    @browser.is_text_present('Jones').should be_true
    @browser.is_text_present('Lab One').should be_true
    @browser.is_text_present('Positive').should be_true
    @browser.is_text_present('Lab Two').should be_true
    @browser.is_text_present('Negative').should be_true
  end

  it "should allow removing a lab result" do
    edit_cmr(@browser)
    @browser.click "remove_lab_result_link"
    @browser.click "event_submit"
    sleep(3)
    @browser.is_text_present('Lab One').should_not be_true
  end

  it "should allow editing lab results" do
    edit_cmr(@browser)
    click_core_tab(@browser, "Laboratory")
    type_field_by_order(@browser, "event_existing_lab_attributes", 0, "Uncertain")
    @browser.click "event_submit"
    sleep(3)
    @browser.is_text_present('Uncertain').should be_true
  end

end
