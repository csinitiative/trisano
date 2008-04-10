require "selenium"
require "test/unit"

class StoryTest1 < Test::Unit::TestCase
  def setup
    @verification_errors = []
    if $selenium
      @selenium = $selenium
    else
      @selenium = Selenium::SeleneseInterpreter.new("localhost", 4444, "*firefox", "http://localhost:4444", 10000);
      @selenium.start
    end
    @selenium.set_context("test_story_test1", "info")
  end
  
  def teardown
    @selenium.stop unless $selenium
    assert_equal [], @verification_errors
  end
  
  def test_story_test1
    @selenium.open "/nedss/"
    @selenium.click "link=CMR Search"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "sw_last_name", "Smoker"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("2008000001")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @selenium.is_text_present("Steve Smoker")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "sw_last_name", ""
    @selenium.type "name", ""
    @selenium.type "name", "smooker stephen"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("2008000001")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @selenium.is_text_present("Steve Smoker")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "name", "chuck smokesalot"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Your search returned no results.")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "name", "stephen smoker"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("2008000001")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @selenium.is_text_present("Steve Smoker")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.type "name", "smooker"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("2008000001")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @selenium.is_text_present("Steve Smoker")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
  end
end
