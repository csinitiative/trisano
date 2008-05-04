require File.dirname(__FILE__) + '/spec_helper'
  
  describe 'User functionality for searching for CMRs by city and county' do
    # the first bunch of tests just makes sure the CMRs are all set up
    before(:each) do
      # The @browser is initialised in spec_helper.rb
      @browser.open('http://utah:arches@ut-nedss-dev.csinitiative.com/nedss/')
    end
    
    it 'should find or add Chuckles in Provo, Utah county' do
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
  
    it 'should find or add Joker in Orem, Utah county' do
      @browser.click('link=View CMRs')
      @browser.wait_for_page_to_load('30000')
      if !@browser.is_text_present('Joker')
        @browser.click('link=New CMR')
        @browser.wait_for_page_to_load('30000')
        @browser.type('event_active_patient__active_primary_entity__person_last_name', 'Joker')
        @browser.type('event_active_patient__active_primary_entity__address_city', 'Orem')
        @browser.select('event_active_patient__active_primary_entity__address_state_id', 'label=Utah')
        @browser.select('event_active_patient__active_primary_entity__address_county_id', 'label=Utah')
        @browser.type('event_active_patient__active_primary_entity__address_postal_code', '84606')
        @browser.click('event_submit')
        @browser.wait_for_page_to_load('30000')
      end
    end
    
    it 'should find or add Papa Smurf in Provo, Utah county' do
      @browser.click('link=View CMRs')
      @browser.wait_for_page_to_load('30000')
      if !@browser.is_text_present('Smurf, Papa')
        @browser.click('link=New CMR')
        @browser.wait_for_page_to_load('30000')
        @browser.type('event_active_patient__active_primary_entity__person_last_name', 'Smurf')
        @browser.type('event_active_patient__active_primary_entity__person_first_name', 'Papa')
        @browser.type('event_active_patient__active_primary_entity__address_city', 'Provo')
        @browser.select('event_active_patient__active_primary_entity__address_state_id', 'label=Utah')
        @browser.select('event_active_patient__active_primary_entity__address_county_id', 'label=Utah')
        @browser.type('event_active_patient__active_primary_entity__address_postal_code', '84602')
        @browser.click('event_submit')
        @browser.wait_for_page_to_load('30000')
      end
    end
    
    it 'should find or add Smurfette in Provo, Utah county' do  
      @browser.click('link=View CMRs')
      @browser.wait_for_page_to_load('30000')
      if !@browser.is_text_present('Smurfette')
        @browser.click('link=New CMR')
        @browser.wait_for_page_to_load('30000')
        @browser.type('event_active_patient__active_primary_entity__person_last_name', 'Smurfette')
        @browser.type('event_active_patient__active_primary_entity__address_city', 'Orem')
        @browser.select('event_active_patient__active_primary_entity__address_state_id', 'label=Utah')
        @browser.select('event_active_patient__active_primary_entity__address_county_id', 'label=Utah')
        @browser.type('event_active_patient__active_primary_entity__address_postal_code', '84606')
        @browser.click('event_submit')
        @browser.wait_for_page_to_load('30000')
      end
    end
   
    it 'should find chuckles and Papa Smurf and not Joker or Smurfette when it searches in city = Provo' do
      @browser.click('link=CMR Search')
      @browser.wait_for_page_to_load('30000')
      @browser.type('name=city', 'Provo')
      @browser.click('//input[@type=\'submit\']')
      @browser.wait_for_page_to_load('30000')
      @browser.is_text_present('chuckles').should be_true
      @browser.is_text_present('Papa Smurf').should be_true
    end
   
    it 'should find Joker and Smurfette and not chuckles or Papa Smurf when it searches in city = Orem' do
      @browser.click('link=CMR Search')
      @browser.wait_for_page_to_load('30000')
      @browser.type('name=city', 'Orem')
      @browser.click('//input[@type=\'submit\']')
      @browser.wait_for_page_to_load('30000')
      @browser.is_text_present('Joker').should be_true
      @browser.is_text_present('Smurfette').should be_true
      @browser.is_text_present('chuckles').should be_false
      @browser.is_text_present('Smurf, Papa').should be_false
    end
   
    it 'should find chuckles, Joker, Smurfette, and Papa Smurf when it searches in county = Utah' do
      @browser.click('link=CMR Search')
      @browser.wait_for_page_to_load('30000')
      @browser.type('name=city', '')
      @browser.select('county', 'label=Utah')
      @browser.click('//input[@type=\'submit\']')
      @browser.wait_for_page_to_load('30000')
      @browser.is_text_present('chuckles').should be_true
      @browser.is_text_present('Joker').should be_true
      @browser.is_text_present('Papa Smurf').should be_true
      @browser.is_text_present('Smurfette').should be_true
    end
    
    it 'should not find chuckles, Joker, Smurfette, or Papa Smurf when it searches in city = Weber' do
      @browser.click('link=CMR Search')
      @browser.wait_for_page_to_load('30000')
      @browser.type('name=city', 'Weber')
      @browser.click('//input[@type=\'submit\']')
      @browser.wait_for_page_to_load('30000')
      @browser.is_text_present('Your search returned no results.').should be_true
    end
    
    it 'should not find chuckles, Joker, Smurfett, or Papa Smurf when it searches in city = Brigham City' do
      @browser.click('link=CMR Search')
      @browser.wait_for_page_to_load('30000')
      @browser.type('name=city', 'Brigham City')
      @browser.click('//input[@type=\'submit\']')
      @browser.wait_for_page_to_load('30000')
      @browser.is_text_present('Your search returned no results.').should be_true
    end
    
    it 'should not find chuckles, Joker, Smurfett, or Papa Smurf when it searches in city = Manti' do
      @browser.click('link=CMR Search')
      @browser.wait_for_page_to_load('30000')
      @browser.type('name=city', 'Manti')
      @browser.click('//input[@type=\'submit\']')
      @browser.wait_for_page_to_load('30000')
      @browser.is_text_present('Your search returned no results.').should be_true
    end
    
    it 'should not find chuckles, Joker, Smurfett, or Papa Smurf when it searches in city = Delta' do
      @browser.click('link=CMR Search')
      @browser.wait_for_page_to_load('30000')
      @browser.type('name=city', 'Delta')
      @browser.click('//input[@type=\'submit\']')
      @browser.wait_for_page_to_load('30000')
      @browser.is_text_present('Your search returned no results.').should be_true
    end
    
    it 'should not find chuckles, Joker, Smurfett, or Papa Smurf when it searches in county = Daggett' do
      @browser.click('link=CMR Search')
      @browser.wait_for_page_to_load('30000')
      @browser.type('name=city', '')
      @browser.select('county', 'label=Daggett')
      @browser.click('//input[@type=\'submit\']')
      @browser.wait_for_page_to_load('30000')
      @browser.is_text_present('Your search returned no results.').should be_true
    end
    
    it 'should not find chuckles, Joker, Smurfett, or Papa Smurf when it searches in county = Garfield' do
      @browser.click('link=CMR Search')
      @browser.wait_for_page_to_load('30000')
      @browser.select('county', 'label=Garfield')
      @browser.click('//input[@type=\'submit\']')
      @browser.wait_for_page_to_load('30000')
      @browser.is_text_present('Your search returned no results.').should be_true
    end
end
