require File.dirname(__FILE__) + '/spec_helper' 
describe "NedssHelper tab navigation" do 
  before(:each) do
    #put any setup tasks here
  end
  it "should find each tab" do 
    @browser.open "/nedss/cmrs"
    @browser.click("link=New CMR")
    @browser.wait_for_page_to_load($load_time)
    NedssHelper.click_core_tab(@browser, "Clinical")
    @browser.is_text_present("Disease Information").should be_true
    NedssHelper.click_core_tab(@browser, "Laboratory")
    @browser.is_text_present("Lab Result").should be_true
    NedssHelper.click_core_tab(@browser, "Epidemiological")
    @browser.is_text_present("Food handler").should be_true
    NedssHelper.click_core_tab(@browser, "Reporting")
    @browser.is_text_present("Reporting Agency").should be_true
    NedssHelper.click_core_tab(@browser, "Administrative")
    @browser.is_text_present("Jurisdiction").should be_true
    @browser.select("event_event_status_id", "label=Under Investigation")
    NedssHelper.click_core_tab(@browser, "Demographics")
    @browser.is_text_present("Person Information").should be_true
    @browser.type("event_active_patient__active_primary_entity__person_last_name", "Tester")
    @browser.type("event_active_patient__active_primary_entity__person_first_name", "Tab")
    @browser.click("event_submit")
    @browser.wait_for_page_to_load($load_time)
    NedssHelper.click_core_tab(@browser, "Investigation")
    @browser.is_text_present("Investigative Information").should be_true
  end
end
