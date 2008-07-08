require File.dirname(__FILE__) + '/spec_helper' 

describe "test2" do
  before(:each) do
    #put any setup tasks here
  end
  it "describe what this thing should do here" do 
    @browser.open "/nedss/"
    @browser.click "link=Forms"
    @browser.wait_for_page_to_load($load_time)
    NedssHelper.click_resource_edit(@browser, "forms", "Marge Not There").should == -1
    NedssHelper.click_resource_show(@browser, "forms", NedssHelper.get_unique_name(4)).should == -1
  end
end
