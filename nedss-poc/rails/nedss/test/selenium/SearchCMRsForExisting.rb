require 'rubygems'
require 'selenium'
require 'test/unit'

class SearchCMRsForExisting < Test::Unit::TestCase

NEDSS_URL = ENV['NEDSS_URL'] ||= 'http://utah:arches@ut-nedss-dev.csinitiative.com'


  def setup
    @verification_errors = []
    if $selenium
      @selenium = $selenium
    else
      @selenium = Selenium::SeleneseInterpreter.new("localhost", 4444, "*firefox", NEDSS_URL, 10000);
      @selenium.start
    end
    @selenium.set_context("test_search_c_m_rs_for_existing", "info")
  end
  
  def teardown
    @selenium.stop unless $selenium
    assert_equal [], @verification_errors
  end
  
  def test_search_c_m_rs_for_existing
    @selenium.open "/nedss/"
    @selenium.click "link=View CMRs"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Smoker")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @selenium.is_text_present("Steve")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.click "link=People Search"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "name", "Smoker"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Steve Smoker")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.click "link=CMR Search"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "name", "Stephen Smoker"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Steve Smoker")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "name", "Stephen Smooker"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Steve Smoker")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "name", "Stephen Smokesalot"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Your search returned no results.")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "name", "Stephen"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Your search returned no results.")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "name", "Steve"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Steve Smoker")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "name", ""
    @selenium.type "sw_first_name", "smo"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Your search returned no results.")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "sw_first_name", ""
    @selenium.type "sw_last_name", "smo"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Steve Smoker")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "sw_last_name", ""
    begin
        assert @selenium.is_text_present("Bear River Health Department")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.select "jurisdiction_id", "label=Bear River Health Department"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Bear River Health Department")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end
end
