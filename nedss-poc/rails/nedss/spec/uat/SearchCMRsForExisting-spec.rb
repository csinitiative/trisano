require File.dirname(__FILE__) + '/spec_helper'

describe 'User functionality for searching for existing users' do

  it 'should find a person named Steve Smoker when viewing all CMRs' do
    @browser.open "/nedss/cmrs"
    @browser.wait_for_page_to_load('30000')
    @browser.is_text_present('Smoker, Steve').should be_true
  end
  
  it 'should find a person named Steve Smoker when searching by Smoker' do
    @browser.click('link=People Search')
    @browser.wait_for_page_to_load('30000') 
    @browser.type('name', 'Smoker')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load('30000') 
    @browser.is_text_present('Smoker, Steve').should be_true
  end
  
  it 'should find a person named Steve Smoker when searching by Stephen Smoker' do
    @browser.click('link=CMR Search')
    @browser.wait_for_page_to_load('30000')
    @browser.type('name', 'Stephen Smoker') 
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load('30000')
    @browser.is_text_present('Smoker, Steve').should be_true
  end
  
  it 'should find a person named Steve Smoker when searching by Stephen Smooker' do
    @browser.type('name', 'Stephen Smooker')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load('30000')
    @browser.is_text_present('Smoker, Steve').should be_true
  end
  
  it 'should not find anyone when searching by Stephen Smokesalot' do
    @browser.type('name', 'Stephen Smokesalot')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load('30000')
    @browser.is_text_present('Your search returned no results.').should be_true
  end
    
  it 'should not find anyone when searching by Stephen' do
    @browser.type('name', 'Stephen')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load('30000')
    @browser.is_text_present('Your search returned no results.').should be_true
  end
  
  it 'should find a person named Steve Smoker when searching by Steve' do
    @browser.type('name', 'Steve')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load('30000')
    @browser.is_text_present('Smoker, Steve').should be_true
  end
  
  it 'should not find anyone when searching by first name smo' do
    @browser.type('name', '')
    @browser.type 'sw_first_name', 'smo'
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load('30000')
    @browser.is_text_present('Your search returned no results.').should be_true
  end
  
  it 'should find a person named Steve Smoker when searching by last name smo' do
    @browser.type('sw_first_name', '')
    @browser.type('sw_last_name', 'smo')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load('30000')
    @browser.is_text_present('Smoker, Steve').should be_true
  end
  
  it 'Steve Smoker should be assigned to Bear River jurisdiction' do
    @browser.type('sw_last_name', '')
    @browser.is_text_present('Bear River Health Department').should be_true
  end

  it 'should find Steve Smoker when searching by Bear River jurisdiction' do  
    @browser.select('jurisdiction_id', 'label=Bear River Health Department')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load('30000')
    @browser.is_text_present('Bear River Health Department').should be_true
  end
end
