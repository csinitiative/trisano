require File.dirname(__FILE__) + '/spec_helper'

describe 'User functionality for searching for existing users' do

  before(:each) do
    # The @browser is initialised in spec_helper.rb
    @browser.open('http://utah:arches@ut-nedss-dev.csinitiative.com')
  end
  it 'should find a person named Steve Smoker when searching by Smoker' do
    @browser.click('link=People Search')
    @browser.wait_for_page_to_load('30000') 
    @browser.type('name', 'Smoker')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load('30000') 
    @browser.is_text_present('Smoker, Steve').should be_true
  end
  
end
