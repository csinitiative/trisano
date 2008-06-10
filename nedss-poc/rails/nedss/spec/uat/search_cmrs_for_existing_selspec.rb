require File.dirname(__FILE__) + '/spec_helper'

describe 'User functionality for searching for existing users' do

  it 'should find or add Charles Chuckles in Provo, Utah county' do
    @browser.open "/nedss/cmrs"
    @browser.click('link=View CMRs')
    @browser.wait_for_page_to_load($load_time)
    if !@browser.is_text_present('Chuckles')
      @browser.click('link=New CMR')
      @browser.wait_for_page_to_load($load_time)
      @browser.type('event_active_patient__active_primary_entity__person_last_name', 'Chuckles')
      @browser.type('event_active_patient__active_primary_entity__person_first_name', 'Charles')
      @browser.type('event_active_patient__active_primary_entity__address_city', 'Provo')
      @browser.select('event_active_patient__active_primary_entity__address_state_id', 'label=Utah')
      @browser.select('event_active_patient__active_primary_entity__address_county_id', 'label=Utah')
      @browser.type('event_active_patient__active_primary_entity__address_postal_code', '84602')
      @browser.click('event_submit')
      @browser.wait_for_page_to_load($load_time)
    end
  end

  it 'should find a person named Charles Chuckles when viewing all CMRs' do
    @browser.open "/nedss/cmrs"
    @browser.click('link=View CMRs')
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Chuckles, Charles').should be_true
  end
  
  it 'should find a person named Charles Chuckles when searching by Chuckles' do
    @browser.click('link=People Search')
    @browser.wait_for_page_to_load($load_time) 
    @browser.type('name', 'Chuckles')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load($load_time) 
    @browser.is_text_present('Charles Chuckles').should be_true
  end
  
  it 'should find a person named Charles Chuckles when searching by Charlie Chuckles' do
    @browser.click('link=CMR Search')
    @browser.wait_for_page_to_load($load_time)
    @browser.type('name', 'Charlie Chuckles') 
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Charles Chuckles').should be_true
  end
  
  it 'should find a person named Charles Chuckles when searching by Charles' do
    @browser.type('name', 'Charles')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Charles Chuckles').should be_true
  end
  
  it 'should not find anyone when searching by Charlie Chuckface' do
    @browser.type('name', 'Charlie Chuckface')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Your search returned no results.').should be_true
  end
    
  it 'should not find anyone when searching by Charlie' do
    @browser.type('name', 'Charlie')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Your search returned no results.').should be_true
  end
  
  it 'should find a person named Charles Chuckles when searching by Chuckles' do
    @browser.type('name', 'Chuckles')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Charles Chuckles').should be_true
  end
  
  it 'should not find anyone when searching by first name chu' do
    @browser.type('name', '')
    @browser.type 'sw_first_name', 'chu'
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Your search returned no results.').should be_true
  end
  
  it 'should find a person named Charles Chuckles when searching by last name chu' do
    @browser.type('sw_first_name', '')
    @browser.type('sw_last_name', 'chu')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Charles Chuckles').should be_true
  end
  
  it 'Charles Chuckles should be assigned to Bear River jurisdiction' do
    @browser.type('sw_last_name', '')
    @browser.is_text_present('Bear River Health Department').should be_true
  end

  it 'should find Charles Chuckles when searching by Bear River jurisdiction' do  
    @browser.select('jurisdiction_id', 'label=Bear River Health Department')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Charles Chuckles').should be_true
    @browser.is_text_present('Bear River Health Department').should be_true
  end
end
