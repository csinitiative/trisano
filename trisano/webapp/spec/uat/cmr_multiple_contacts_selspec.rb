require File.dirname(__FILE__) + '/spec_helper'

$dont_kill_browser = true

describe 'Adding multiple contacts to a CMR' do
  
  it "should allow adding new contacts to a new CMR" do
    @browser.open "/nedss/cmrs"
    click_nav_new_cmr(@browser)
    @browser.type "morbidity_event_active_patient__active_primary_entity__person_last_name", "Headroom"
    @browser.type "morbidity_event_active_patient__active_primary_entity__person_first_name", "Max"

    click_core_tab(@browser, "Contacts")
    @browser.click "link=Add a contact"
    sleep(1)
    @browser.type "//div[@class='contact'][1]//input[contains(@id, 'last_name')]", "Costello"
    @browser.type "//div[@class='contact'][1]//input[contains(@id, 'first_name')]", "Lou"
    @browser.type "//div[@class='contact'][2]//input[contains(@id, 'last_name')]", "Abbott"
    @browser.type "//div[@class='contact'][2]//input[contains(@id, 'first_name')]", "Bud"

    save_cmr(@browser).should be_true

    @browser.is_text_present('CMR was successfully created.').should be_true
    @browser.is_text_present('Costello').should be_true
    @browser.is_text_present('Lou').should be_true
    @browser.is_text_present('Abbott').should be_true
    @browser.is_text_present('Bud').should be_true
  end

  it "should allow removing a contact" do
    edit_cmr(@browser)
    click_core_tab(@browser, "Contacts")
    @browser.click "remove_contact_link"
    @browser.click "morbidity_event_submit"
    sleep(3)
    @browser.is_text_present('Costello').should_not be_true
  end

  it "should allow editing a contact" do
    edit_cmr(@browser)
    click_core_tab(@browser, "Contacts")
    @browser.type "//div[@class='contact'][1]//input[contains(@id, 'first_name')]", "William"
    @browser.click "morbidity_event_submit"
    sleep(3)
    @browser.is_text_present('William').should be_true
  end

end
