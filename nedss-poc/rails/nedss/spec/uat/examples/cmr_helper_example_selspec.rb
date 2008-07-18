require File.dirname(__FILE__) + './spec_helper' 
$dont_kill_browser = true

describe "cmr helper example" do 
  before(:each) do
    #put any setup tasks here
  end
  
  before(:each) do
    #put any setup tasks here
  end
  
  it "should create a cmr from a hash of field names and values" do 
    @browser.open("/nedss/forms")
    @browser.wait_for_page_to_load("30000")
    cmr_hash = NedssHelper.get_full_cmr_hash()
    NedssHelper.create_cmr_from_hash(@browser, cmr_hash)
  end
end














