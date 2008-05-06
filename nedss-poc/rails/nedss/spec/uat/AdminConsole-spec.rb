require File.dirname(__FILE__) + '/spec_helper'
  
  describe 'The UT-NEDSS Admin Console' do 
    before(:each) do
      # The @browser is initialised in spec_helper.rb
      @browser.open('http://utah:arches@ut-nedss-dev.csinitiative.com/nedss/')
    end

    after(:each) do
      @browser.close
    end
  
  it 'should load successfully' do
    @browser.click "link=Home"
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present("UT-NEDSS Admin Console")
  end
  
  it 'should let you do something' 
end

