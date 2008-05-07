require File.dirname(__FILE__) + '/spec_helper'
  
  describe 'The UT-NEDSS home page' do 
    before(:each) do
      # The @browser is initialised in spec_helper.rb
      @browser.open('http://utah:arches@ut-nedss-dev.csinitiative.com/nedss/')
    end

    after(:each) do
      @browser.close
    end
    
    it 'should have links to all the sub-pages' do
      @browser.wait_for_page_to_load '30000'
      #First check for all the links that should be there
      @browser.is_text_present('View CMRs').should be_true
      @browser.is_text_present('New CMR').should be_true
      @browser.is_text_present('People Search').should be_true
      @browser.is_text_present('CMR Search').should be_true
      @browser.is_text_present('Admin Home').should be_true
      @browser.is_text_present('Forms').should be_true
      @browser.is_text_present('Users').should be_true
    end
    
    it 'should have labels describing the home page' do
      #Then check for the various text lables on the home page
      @browser.is_text_present('Welcome to the UT-NEDSS National Electronic Disease Surveillance System').should be_true
      @browser.is_text_present('UT-NEDSS Home').should be_true
      @browser.is_text_present('UT-NEDSS Utah - National Electronic Disease Surveillance System').should be_true
      @browser.is_text_present('UT-NEDSS Home').should be_true
    end
    
    it 'should correctly identify the user' do
      @browser.is_text_present('User: default_user').should be_true
    end

    it 'should navigate successfully to the home page' do    
      @browser.click 'link=UT-NEDSS Utah - National Electronic Disease Surveillance System'
      @browser.wait_for_page_to_load '30000'
      @browser.is_text_present('UT-NEDSS Home').should be_true
    end
    
    it 'should navigate successfully to the Admin page' do
      @browser.click 'link=Admin Home'
      @browser.wait_for_page_to_load '30000'
      @browser.is_text_present('UT-NEDSS Admin Console').should be_true
    end
    
    it 'should navigate successfully to the People Search page' do
      @browser.click 'link=People Search'
      @browser.wait_for_page_to_load '30000'
      @browser.is_text_present('People Search').should be_true
    end
    
    it 'should navigate successfully to the CMR Search page' do
      @browser.click 'link=CMR Search'
      @browser.wait_for_page_to_load '30000'
      @browser.is_text_present('CMR Search').should be_true
    end
    
    it 'should navigate successfully to the View CMRs page' do
      @browser.click 'link=View CMRs'
      @browser.wait_for_page_to_load '30000'
      @browser.is_text_present('Listing Confidential Morbidity Reports').should be_true
    end
    
    it 'should navigate successfully to the New CMR page' do
      @browser.click 'link=New CMR'
      @browser.wait_for_page_to_load '30000'
      @browser.is_text_present('New Confidential Morbidity Report').should be_true
    end
    
    it 'should navigate successfully to the Forms page' do
      @browser.click 'link=Forms'
      @browser.wait_for_page_to_load('30000')
      @browser.is_text_present('Listing forms').should be_true
    end
    
    it 'should navigate successfully to the Users page' do
      @browser.click('link=Users')
      @browser.wait_for_page_to_load('30000')
      @browser.is_text_present('Listing users').should be_true
    end
  end

