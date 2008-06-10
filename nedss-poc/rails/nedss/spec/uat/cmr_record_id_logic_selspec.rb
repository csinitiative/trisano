require File.dirname(__FILE__) + '/spec_helper'

describe 'Sytem functionality for setting the record ID of a CMR' do

  it 'should create two CMRs in a row with sequential record numbers that start with the current year' do
    @browser.open "/nedss/cmrs"
    @browser.click('link=New CMR')
    @browser.wait_for_page_to_load($load_time)
    @browser.type('event_active_patient__active_primary_entity__person_last_name', 'Record')
    @browser.type('event_active_patient__active_primary_entity__person_first_name', 'Number')
    @browser.click('event_submit')
    @browser.wait_for_page_to_load($load_time)
    recNum = @browser.get_text('//div[2]/fieldset/table/tbody/tr[1]/td[2]')
    puts "First record ID is " + recNum
    
    @browser.click('link=New CMR')
    @browser.wait_for_page_to_load($load_time)
    @browser.type('event_active_patient__active_primary_entity__person_last_name', 'Next')
    @browser.type('event_active_patient__active_primary_entity__person_first_name', 'Record')
    @browser.click('event_submit')
    @browser.wait_for_page_to_load($load_time)
    @browser.click('//li[2]/a/em')
    
    nextRecNum = @browser.get_text('//div[2]/fieldset/table/tbody/tr[1]/td[2]')
    puts "Second record ID is " + nextRecNum
    
    ((nextRecNum.to_i - recNum.to_i)==1).should be_true
    (recNum[0,4]==Time.now.year.to_s).should be_true
    (nextRecNum[0,4]==Time.now.year.to_s).should be_true
  end
end
