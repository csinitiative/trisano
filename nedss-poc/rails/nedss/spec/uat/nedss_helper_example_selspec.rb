require File.dirname(__FILE__) + '/spec_helper' 

describe "test2" do 
  before(:each) do
    #put any setup tasks here
  end
  it "describe what this thing should do here" do 
    @browser.open "/nedss/"
    @browser.click "link=Forms"
    @browser.wait_for_page_to_load "30000"
    NedssHelper.edit_form(@browser, "Marge Not There").should == -1
    NedssHelper.edit_form(@browser, NedssHelper.get_unique_name(4)).should == -1
  end
end
