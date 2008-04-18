require 'rubygems'
require 'selenium'
require 'test/unit'

class CityCountyCMRSearch < Test::Unit::TestCase
 NEDSS_URL = ENV['NEDSS_URL'] ||= 'http://utah:arches@ut-nedss-dev.csinitiative.com'

  def setup
    @verification_errors = []
    if $selenium
      @selenium = $selenium
    else
      @selenium = Selenium::SeleneseInterpreter.new("localhost", 4444, "*firefox", NEDSS_URL, 10000);
      @selenium.start
    end
    @selenium.set_context("test_city_county_c_m_r_search")
  end
  
  def teardown
    @selenium.stop unless $selenium
    assert_equal [], @verification_errors
  end
  
  def test_city_county_c_m_r_search
    @selenium.open "/nedss/"
    @selenium.click "link=View CMRs"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=New CMR"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "event_active_patient__active_primary_entity__person_last_name", "chuckles"
    @selenium.type "event_active_patient__active_primary_entity__address_city", "Provo"
    @selenium.select "event_active_patient__active_primary_entity__address_state_id", "label=Utah"
    @selenium.select "event_active_patient__active_primary_entity__address_county_id", "label=Utah"
    @selenium.type "event_active_patient__active_primary_entity__address_postal_code", "84602"
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=New CMR"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "event_active_patient__active_primary_entity__person_last_name", "Joker"
    @selenium.type "event_active_patient__active_primary_entity__address_city", "Orem"
    @selenium.select "event_active_patient__active_primary_entity__address_state_id", "label=Utah"
    @selenium.select "event_active_patient__active_primary_entity__address_county_id", "label=Utah"
    @selenium.type "event_active_patient__active_primary_entity__address_postal_code", "84606"
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=View CMRs"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=New CMR"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "event_active_patient__active_primary_entity__person_last_name", "Smurf"
    @selenium.type "event_active_patient__active_primary_entity__person_first_name", "Papa"
    @selenium.type "event_active_patient__active_primary_entity__address_city", "Provo"
    @selenium.select "event_active_patient__active_primary_entity__address_state_id", "label=Utah"
    @selenium.select "event_active_patient__active_primary_entity__address_county_id", "label=Utah"
    @selenium.type "event_active_patient__active_primary_entity__address_postal_code", "84602"
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=New CMR"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "event_active_patient__active_primary_entity__person_last_name", "Smurfette"
    @selenium.type "event_active_patient__active_primary_entity__address_city", "Orem"
    @selenium.select "event_active_patient__active_primary_entity__address_state_id", "label=Utah"
    @selenium.select "event_active_patient__active_primary_entity__address_county_id", "label=Utah"
    @selenium.type "event_active_patient__active_primary_entity__address_postal_code", "84606"
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=CMR Search"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "name=city", "Provo"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("chuckles")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @selenium.is_text_present("Papa Smurf")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "name=city", "Orem"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Joker")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @selenium.is_text_present("Smurfette")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "name=city", ""
    @selenium.select "county", "label=Utah"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("chuckles")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @selenium.is_text_present("Joker")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @selenium.is_text_present("Papa Smurf")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @selenium.is_text_present("Smurfette")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.click "link=CMR Search"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "name=city", "Weber"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Your search returned no results.")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "name=city", "Brigham City"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Your search returned no results.")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "name=city", "Manti"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Your search returned no results.")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "name=city", "Delta"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Your search returned no results.")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "name=city", ""
    @selenium.select "county", "label=Daggett"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Your search returned no results.")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.select "county", "label=Garfield"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Your search returned no results.")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end
end
