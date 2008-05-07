require File.dirname(__FILE__) + '/spec_helper'
  
  describe 'The UT-NEDSS Admin Console' do 
 
  it 'should load successfully' do
    @browser.open "/nedss/cmrs"
    @browser.click "link=Home"
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present("UT-NEDSS Admin Console")
  end
  
  it 'should let you do something' 
end

