require File.dirname(__FILE__) + '/spec_helper'

describe "Creating a CMR with minimal data" do
  
  it "should create a CMR when the user provides only the person's last name" do
    @browser.open('/nedss/')
    click_nav_new_cmr(@browser)
    @browser.type('event_active_patient__active_primary_entity__person_last_name','Joker')
    save_cmr(@browser)
    @browser.is_text_present("CMR was successfully created.").should be_true
  end
end
