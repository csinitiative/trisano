require File.dirname(__FILE__) + '/spec_helper'
  
  describe 'The UT-NEDSS Admin Console' do
    
  # $dont_kill_browser = true
 
  it 'should load successfully' do
    @browser.open "/nedss/cmrs"
    click_nav_admin(@browser)
    @browser.is_text_present("UT-NEDSS Admin Console")
  end
end

