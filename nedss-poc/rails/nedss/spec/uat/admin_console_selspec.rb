require File.dirname(__FILE__) + '/spec_helper'
  
  describe 'The UT-NEDSS Admin Console' do
    
  # $dont_kill_browser = true
 
  it 'should load successfully' do
    @browser.open "/nedss/cmrs"
    click_nav_admin(@browser).should be_true
  end
end

