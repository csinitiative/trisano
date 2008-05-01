require File.dirname(__FILE__) + '/spec_helper'

describe 'User functionality for searching for existing users' do

  before(:each) do
    # The @browser is initialised in spec_helper.rb
    @browser.open('http://utah:arches@ut-nedss-dev.csinitiative.com')
  end
  it "should find a person named Steve Smoker when viewing all CMRs" do
    @browser.open('/nedss/')
    @browser.click('link=View CMRs')
    @browser.wait_for_page_to_load('30000')
    @browser.is_text_present('Smoker, Steve').should be_true
  end
  
end
