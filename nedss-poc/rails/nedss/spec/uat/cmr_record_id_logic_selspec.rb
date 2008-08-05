require File.dirname(__FILE__) + '/spec_helper'

describe 'System functionality for setting the record ID of a CMR' do

  it 'should create two CMRs in a row with sequential record numbers that start with the current year' do
    @browser.open "/nedss/cmrs"
    click_nav_new_cmr(@browser).should be_true
    @browser.type('morbidity_event_active_patient__active_primary_entity__person_last_name', 'Record')
    @browser.type('morbidity_event_active_patient__active_primary_entity__person_first_name', 'Number')
    save_cmr(@browser).should be_true
    recNum = get_record_number(@browser)
    click_nav_new_cmr(@browser).should be_true
    @browser.type('morbidity_event_active_patient__active_primary_entity__person_last_name', 'Next')
    @browser.type('morbidity_event_active_patient__active_primary_entity__person_first_name', 'Record')
    save_cmr(@browser).should be_true
    click_core_tab(@browser, "Clinical")
    nextRecNum = get_record_number(@browser)
    ((nextRecNum.to_i - recNum.to_i)==1).should be_true
    (recNum[0,4]==Time.now.year.to_s).should be_true
    (nextRecNum[0,4]==Time.now.year.to_s).should be_true
  end
end
