require File.dirname(__FILE__) + '/spec_helper'

describe "Creating a CMR with minimal data" do
  before(:each) do
    # The @browser is initialised in spec_helper.rb
    @browser.open('http://utah:arches@ut-nedss-dev.csinitiative.com')
  end
  
  it "should create a CMR when the user provides only the person's last name" do
    @browser.open('/nedss/')
    @browser.click('link=New CMR')
    @browser.wait_for_page_to_load(30000)
    @browser.type('event_active_patient__active_primary_entity__person_last_name','Joker')
    @browser.click('event_submit')
    @browser.wait_for_page_to_load(30000)
    @browser.is_text_present(
          "CMR was successfully created.").should be_true
  end
end