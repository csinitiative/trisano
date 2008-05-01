require 'rubygems'
require 'selenium'
require 'test/unit'

class SimpleCMRCreate < Test::Unit::TestCase
 NEDSS_URL = ENV['NEDSS_URL'] ||= 'http://utah:arches@ut-nedss-dev.csinitiative.com'

  def setup
    @verification_errors = []
    if $selenium
      @selenium = $selenium
    else
      @selenium = Selenium::SeleneseInterpreter.new("localhost", 4444, "*firefox", NEDSS_URL, 10000);
      @selenium.start
    end
    @selenium.set_context("test_simple_c_m_r_create")
  end
  
  def teardown
    @selenium.stop unless $selenium
    assert_equal [], @verification_errors
  end
  
  def test_simple_c_m_r_create
    @selenium.open "/nedss/"
    @selenium.click "link=New CMR"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "event_active_patient__active_primary_entity__person_last_name", "Joker"
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("CMR was successfully created.")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end
end
