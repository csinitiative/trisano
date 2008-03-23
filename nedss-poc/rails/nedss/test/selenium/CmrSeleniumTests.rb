require 'rubygems'
require 'selenium'
require 'test/unit'

class CmrSeleniumTests < Test::Unit::TestCase

  NEDSS_URL = ENV['NEDSS_URL'] ||= 'http://utah:arches@ut-nedss-dev.csinitiative.com'
 

  def setup
    @verification_errors = []
    if $selenium
      @selenium = $selenium
    else
      @selenium = Selenium::SeleneseInterpreter.new("localhost", 4444, "*firefox", NEDSS_URL, 10000);
      @selenium.start
    end
    @selenium.set_context("test_cmr")
  end
  
  def teardown
    @selenium.stop unless $selenium
    assert_equal [], @verification_errors
  end

  def test_mmwr
    @selenium.open "/nedss/cmrs"
    @selenium.click "link=New CMR"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "event_active_patient__active_primary_entity__person_last_name", "Mmwr"
    @selenium.type "event_active_patient__active_primary_entity__person_first_name", "Test"
    @selenium.type "event_active_patient__active_primary_entity__person_middle_name", "Selenium"
    @selenium.click "//ul[@id='tabs']/li[2]/a/em"
    @selenium.click "//img[@onclick='new CalendarDateSelect( $(this).previous(), {year_range:[2003, 2008]} );']"
    @selenium.select "//select[2]", "label=2007"
    @selenium.click "//option[@value='2007']"
    @selenium.click "//tr[3]/td[3]/div"
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "//ul[@id='tabs']/li[6]/a/em"
    begin
        assert @selenium.is_text_present("11")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end

  def test_age
    @selenium.open "/nedss/cmrs"
    @selenium.click "link=New CMR"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "event_active_patient__active_primary_entity__person_last_name", "Age"
    @selenium.type "event_active_patient__active_primary_entity__person_first_name", "Test"
    @selenium.type "event_active_patient__active_primary_entity__person_middle_name", "Selenium"
    @selenium.click "//img[@alt='Calendar']"
    @selenium.select "//select[2]", "label=1978"
    @selenium.click "//tr[2]/td[5]/div"
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("30")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end

  def test_cmr_edit
    @selenium.open "/nedss/cmrs"
    @selenium.click "link=New CMR"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "event_active_patient__active_primary_entity__person_last_name", "Cmredit"
    @selenium.type "event_active_patient__active_primary_entity__person_first_name", "Selenium"
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Edit"
    @selenium.wait_for_page_to_load "30000"
    @selenium.select "event_active_patient__active_primary_entity__person_birth_gender_id", "label=Female"
    @selenium.select "event_active_patient__active_primary_entity__person_ethnicity_id", "label=Hispanic or Latino"
    @selenium.add_selection "event_active_patient__active_primary_entity_race_ids", "label=White"
    @selenium.add_selection "event_active_patient__active_primary_entity_race_ids", "label=Black / African-American"
    @selenium.add_selection "event_active_patient__active_primary_entity_race_ids", "label=American Indian"
    @selenium.add_selection "event_active_patient__active_primary_entity_race_ids", "label=Asian"
    @selenium.add_selection "event_active_patient__active_primary_entity_race_ids", "label=Alaskan Native"
    @selenium.add_selection "event_active_patient__active_primary_entity_race_ids", "label=Native Hawaiian / Pacific Islander"
    @selenium.select "event_active_patient__active_primary_entity__person_primary_language_id", "label=Japanese"
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Edit")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @selenium.is_text_present("Edit")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @selenium.is_text_present("Selenium")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @selenium.is_text_present("Japanese")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end

  def test_people_search_dob
    @selenium.open "/nedss/cmrs"
    @selenium.click "link=New CMR"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "event_active_patient__active_primary_entity__person_last_name", "Lastnamesearch"
    @selenium.type "event_active_patient__active_primary_entity__person_first_name", "Kyle"
    @selenium.click "//img[@alt='Calendar']"
    @selenium.select "//select[2]", "label=1920"
    @selenium.click "//tr[2]/td[3]/div"
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=People Search"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "birth_date", "03/02/1920"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Kyle Lastnamesearch")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end

  def test_people_search_name
    @selenium.open "/nedss/cmrs"
    @selenium.click "link=New CMR"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "event_active_patient__active_primary_entity__person_last_name", "Hit"
    @selenium.type "event_active_patient__active_primary_entity__person_first_name", "Search"
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=People Search"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "name", "Hit"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Search Hit")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end

end
