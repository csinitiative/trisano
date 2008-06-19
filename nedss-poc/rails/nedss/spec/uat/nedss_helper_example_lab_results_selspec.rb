require File.dirname(__FILE__) + '/spec_helper' 
#$dont_kill_browser = true

describe "nedss_helper_example_lab_results_selspec" do 

  before(:all) do
    @cmr_name = NedssHelper.get_unique_name(1)  
  end
  
  before(:each) do
    #put any setup tasks here
  end
  
  it "should create a CMR with 3 lab results" do 
    @browser.open("/nedss/cmrs")
    @browser.click("link=New CMR")
    @browser.wait_for_page_to_load($load_time)
    @browser.type("event_active_patient__active_primary_entity__person_last_name", @cmr_name)
    @browser.click_core_tab(@browser, "Laboratory")
    @browser.type("event_lab_result_lab_result_text", "Lab Result 1")
    @browser.select("event_lab_result_specimen_source_id", "label=Blood")
    @browser.click("event_submit")
    @browser.wait_for_page_to_load($load_time)
    @browser.click("edit_cmr_link")
    @browser.wait_for_page_to_load($load_time)
    @browser.click_core_tab(@browser, "Laboratory")
    @browser.click("link=New Lab Result")
    sleep 2 #because the following doesn't currently work
    #wait_for_element_present("new-lab-result-form")
    @browser. type("lab_result_lab_result_text", "Lab result 2")
    @browser.select("lab_result_specimen_source_id", "label=Eye Swab/Wash")
    @browser.click("save-button")
    @browser.click("link=New Lab Result")
    sleep 2
    #wait_for_element_present("new-lab-result-form")
    @browser. type("lab_result_lab_result_text", "Lab result 2")
    @browser.select("lab_result_specimen_source_id", "label=Nasopharyngeal Swab")
    @browser.click("save-button")
    @browser.click("event_submit")
    @browser.wait_for_page_to_load($load_time)
    @browser.click_core_tab(@browser, "Laboratory")
  end
  
  it "should click the second lab result" do
    NedssHelper.click_link_by_order(@browser, "edit-lab-result", 2)
  end
end
