require 'rubygems'
require 'selenium'
require 'test/unit'

class CreateCMRWithDemographicsOnly < Test::Unit::TestCase

NEDSS_URL = ENV['NEDSS_URL'] ||= 'http://utah:arches@ut-nedss-dev.csinitiative.com'

  def setup
    @verification_errors = []
    if $selenium
      @selenium = $selenium
    else
      @selenium = Selenium::SeleneseInterpreter.new("localhost", 4444, "*firefox", NEDSS_URL, 10000);
      @selenium.start
    end
    @selenium.set_context("test_create_c_m_r_with_demographics_only")
  end
  
  def teardown
    @selenium.stop unless $selenium
    assert_equal [], @verification_errors
  end
  
  def test_create_c_m_r_with_demographics_only
    @selenium.open "/nedss/"
    @selenium.click "link=New CMR"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "event_active_patient__active_primary_entity__person_last_name", "Christiansen"
    @selenium.type "event_active_patient__active_primary_entity__person_first_name", "David"
    @selenium.type "event_active_patient__active_primary_entity__address_street_number", "123"
    @selenium.type "event_active_patient__active_primary_entity__address_street_name", "My Street"
    @selenium.type "event_active_patient__active_primary_entity__address_city", "Hometown"
    @selenium.select "event_active_patient__active_primary_entity__address_state_id", "label=Texas"
    @selenium.select "event_active_patient__active_primary_entity__address_county_id", "label=Out-of-state"
    @selenium.click "//img[@alt='Calendar']"
    @selenium.select "//select[2]", "label=1989"
    @selenium.click "//img[@alt='Calendar']"
    @selenium.select "//select[2]", "label=1989"
    @selenium.type "event_active_patient__active_primary_entity__person_approximate_age_no_birthday", "34"
    @selenium.type "event_active_patient__active_primary_entity__telephone_area_code", "333"
    @selenium.type "event_active_patient__active_primary_entity__telephone_phone_number", "555abcd"
    @selenium.select "event_active_patient__active_primary_entity__person_birth_gender_id", "label=Male"
    @selenium.select "event_active_patient__active_primary_entity__person_ethnicity_id", "label=Not Hispanic or Latino"
    @selenium.add_selection "event_active_patient__active_primary_entity_race_ids", "label=White"
    @selenium.select "event_active_patient__active_primary_entity__person_primary_language_id", "label=Hmong"
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Phone number must not be blank and must be 7 digits with an optional dash (e.g.5551212 or 555-1212)")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "event_active_patient__active_primary_entity__telephone_phone_number", "5551234"
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "//li[2]/a/em"
    @selenium.click "link=Edit"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "//li[2]/a/em"
    @selenium.select "event_disease_disease_id", "label=Anaplasma phagocytophilum"
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "//li[2]/a/em"
    @selenium.click "link=Edit"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Person Information")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=People Search"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "name", "Christenson"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "name", "Christian"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("David Christiansen")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "name", "Kristen"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Your search returned no results.")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "name", "David"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("19 / 1989-04-05")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end
end
