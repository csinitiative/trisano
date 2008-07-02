require File.dirname(__FILE__) + '/spec_helper'

  describe 'The UT-NEDSS home page' do 
    
    it 'should have links to all the sub-pages' do
      @browser.open "/nedss/cmrs"
      @browser.wait_for_page_to_load($load_time)
      #First check for all the links that should be there
      @browser.is_text_present('CMRS').should be_true
      @browser.is_text_present('NEW CMR').should be_true
      @browser.is_text_present('SEARCH').should be_true
      @browser.is_text_present('ADMIN').should be_true
      @browser.is_text_present('FORMS').should be_true
    end
    
    it 'should have a logo on the home page' do
      #Then check for the various text lables on the home page
      @browser.is_element_present('//img[@alt=\'Logo\']').should be_true
    end
    
    it 'should correctly identify the user' do
      @browser.is_text_present('default_user').should be_true
    end

    it 'should navigate successfully to the home page' do    
      @browser.click '//img[@alt=\'Logo\']'
      @browser.wait_for_page_to_load($load_time)
      @browser.is_text_present('UT-NEDSS Home').should be_true
    end
    
    it 'should navigate successfully to the Admin page' do
      @browser.click 'link=ADMIN'
      @browser.wait_for_page_to_load($load_time)
      @browser.is_text_present('UT-NEDSS Admin Console').should be_true
    end
    
    it 'should navigate successfully to the People Search page' do
      @browser.click 'link=SEARCH'
      @browser.wait_for_page_to_load($load_time)
      @browser.click 'link=People Search'
      @browser.wait_for_page_to_load($load_time)
      @browser.is_text_present('People Search').should be_true
    end
    
    it 'should navigate successfully to the CMR Search page' do
      @browser.click 'link=SEARCH'
      @browser.wait_for_page_to_load($load_time)
      @browser.click 'link=CMR Search'
      @browser.wait_for_page_to_load($load_time)
      @browser.is_text_present('CMR Search').should be_true
    end
    
    it 'should navigate successfully to the View CMRs page' do
      @browser.click 'link=CMRS'
      @browser.wait_for_page_to_load($load_time)
      @browser.is_text_present('Listing Confidential Morbidity Reports').should be_true
    end
    
    it 'should navigate successfully to the New CMR page' do
      @browser.click 'link=NEW CMR'
      @browser.wait_for_page_to_load($load_time)
      @browser.is_text_present('New Confidential Morbidity Report').should be_true
    end
    
    it 'should navigate successfully to the Forms page' do
      @browser.click 'link=ADMIN'
      @browser.wait_for_page_to_load($load_time)
      @browser.click 'link=Forms'
      @browser.wait_for_page_to_load($load_time)
      @browser.is_text_present('Listing forms').should be_true
    end
    
    it 'should navigate successfully to the Users page' do
      @browser.click 'link=ADMIN'
      @browser.wait_for_page_to_load($load_time)
      @browser.click('link=Users')
      @browser.wait_for_page_to_load($load_time)
      @browser.is_text_present('Listing users').should be_true
    end
  end

