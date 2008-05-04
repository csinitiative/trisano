require File.dirname(__FILE__) + '/spec_helper'

describe 'User functionality for searching for existing users' do

  before(:each) do
    # The @browser is initialised in spec_helper.rb
    @browser.open('http://utah:arches@ut-nedss-dev.csinitiative.com/nedss/')
  end
  it 'should find or add a Chuckles in Provo, Utah county' do
    @browser.click('link=View CMRs')
    @browser.wait_for_page_to_load('30000')
    if !@browser.is_text_present('chuckles')
      @browser.click('link=New CMR')
      @browser.wait_for_page_to_load('30000')
      @browser.type('event_active_patient__active_primary_entity__person_last_name', 'chuckles')
      @browser.type('event_active_patient__active_primary_entity__address_city', 'Provo')
      @browser.select('event_active_patient__active_primary_entity__address_state_id', 'label=Utah')
      @browser.select('event_active_patient__active_primary_entity__address_county_id', 'label=Utah')
      @browser.type('event_active_patient__active_primary_entity__address_postal_code', '84602')
      @browser.click('event_submit')
      @browser.wait_for_page_to_load('30000')
    end
  end
  
end
