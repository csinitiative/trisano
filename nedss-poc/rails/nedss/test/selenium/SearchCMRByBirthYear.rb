require 'rubygems'
require 'selenium'
require 'test/unit'

class SearchCMRByBirthYear < Test::Unit::TestCase
 NEDSS_URL = ENV['NEDSS_URL'] ||= 'http://utah:arches@ut-nedss-dev.csinitiative.com'

  def setup
    @verification_errors = []
    if $selenium
      @selenium = $selenium
    else
      @selenium = Selenium::SeleneseInterpreter.new("localhost", 4444, "*firefox", NEDSS_URL, 10000);
      @selenium.start
    end
    @selenium.set_context("test_search_c_m_r_by_birth_year")
  end
  
  def teardown
    @selenium.stop unless $selenium
    assert_equal [], @verification_errors
  end
  
  def test_search_c_m_r_by_birth_year
    @selenium.open "/nedss/"
    @selenium.click "link=New CMR"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "event_active_patient__active_primary_entity__person_last_name", "Duck"
    @selenium.type "event_active_patient__active_primary_entity__person_first_name", "Chuck"
    @selenium.type "event_active_patient__active_primary_entity__person_birth_date", "4/1/1945"
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=New CMR"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "event_active_patient__active_primary_entity__person_last_name", "Dock"
    @selenium.type "event_active_patient__active_primary_entity__person_first_name", "Chock"
    @selenium.type "event_active_patient__active_primary_entity__person_birth_date", "5/1/1945"
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=New CMR"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "event_active_patient__active_primary_entity__person_birth_date", "2/29/1984"
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "event_active_patient__active_primary_entity__person_last_name", "Stock"
    @selenium.type "event_active_patient__active_primary_entity__person_first_name", "Block"
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=View CMRs"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Stock")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @selenium.is_text_present("Dock")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @selenium.is_text_present("Duck")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.click "link=People Search"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "birth_date", "1945"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("There was a problem with your search criteria. Please try again.")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.click "link=CMR Search"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "birth_date", "1945"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Chock Dock")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @selenium.is_text_present("Chuck Duck")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert !@selenium.is_text_present("Block Stock")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "birth_date", "1944"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Your search returned no results.")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "birth_date", "1946"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Your search returned no results.")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "birth_date", "2045"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Your search returned no results.")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "birth_date", "1845"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Your search returned no results.")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "birth_date", "45"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Invalid birth date format")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "birth_date", "1984"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Block Stock")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert !@selenium.is_text_present("Chock Dock")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert !@selenium.is_text_present("Chuck Duck")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end
end
