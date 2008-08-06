require File.dirname(__FILE__) + '/spec_helper' 
$dont_kill_browser = true

describe "lab results helper" do
  it "should add a lab result to an existing CMR" do
    @lab_result_fields = {
      "lab_result_lab_result_text" => NedssHelper.get_unique_name(2),
      "lab_result_specimen_source_id" => "Cervical Swab",
      "lab_result_collection_date" => "5/12/2008",
      "lab_result_lab_test_date" => "5/15/2008",
      "lab_result_specimen_sent_to_uphl_yn_id" => "Yes"
    }
    @browser.open("/nedss/cmrs")
    @browser.click("link=Edit")
    @browser.wait_for_page_to_load($load_time)
    @browser.click("link=New Lab Result")
    sleep 3
    NedssHelper.set_fields(@browser, @lab_result_fields)
    @browser.click("save-button")
    sleep 3
    @browser.click('event_submit')
    @browser.wait_for_page_to_load($load_time)
  end
end

