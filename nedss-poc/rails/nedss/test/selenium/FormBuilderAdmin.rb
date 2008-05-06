require "selenium"
require "test/unit"

class NewTest < Test::Unit::TestCase
  def setup
    @verification_errors = []
    if $selenium
      @selenium = $selenium
    else
      @selenium = Selenium::SeleneseInterpreter.new("localhost", 4444, "*chrome", "http://change-this-to-the-site-you-are-testing/", 10000);
      @selenium.start
    end
    @selenium.set_context("test_new")
  end
  
  def teardown
    @selenium.stop unless $selenium
    assert_equal [], @verification_errors
  end
  
  def test_new
    @selenium.open "/"
    @selenium.click "link=Forms"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=New form"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "form_name", "African Tick Bite Test"
    @selenium.click "form_submit"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Form Builder"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Add a question"
    sleep 2
    assert @selenium.is_element_present("new-question-form")
    @selenium.type "question_question_text", "Did you go into the tall grass?"
    @selenium.select "question_data_type", "label=Drop-down select list"
    @selenium.click "question_submit"
    sleep 2
    assert !@selenium.is_element_present("new-question-form")
    assert @selenium.is_text_present("Did you go into the tall grass?")
    @selenium.click "link=Add a question"
    sleep 2
    assert @selenium.is_element_present("new-question-form")
    @selenium.type "question_question_text", "Did you see the tick that got you?"
    @selenium.select "question_data_type", "label=Radio buttons"
    @selenium.click "question_submit"
    sleep 2
    assert !@selenium.is_element_present("new-question-form")
    assert @selenium.is_text_present("Did you see the tick that got you?")
    @selenium.click "link=Add a question"
    sleep 2
    assert @selenium.is_element_present("new-question-form")
    @selenium.type "question_question_text", "Describe the tick."
    @selenium.select "question_data_type", "label=Multi-line text"
    @selenium.click "question_submit"
    sleep 2
    assert !@selenium.is_element_present("new-question-form")
    assert @selenium.is_text_present("Describe the tick.")
    @selenium.click "link=Add a question"
    sleep 2
    assert @selenium.is_element_present("new-question-form")
    @selenium.type "question_question_text", "Could you describe the tick?"
    @selenium.select "question_data_type", "label=Radio buttons"
    @selenium.click "question_submit"
    sleep 2
    assert !@selenium.is_element_present("new-question-form")
    assert @selenium.is_text_present("Could you describe the tick?")
    @selenium.click "link=Add value set"
    sleep 2
    assert @selenium.is_element_present("new-value-set-form")
    @selenium.type "value_set_element_name", "Yes/No/Maybe"
    @selenium.click "link=Add a value"
    @selenium.click "link=Add a value"
    @selenium.click "link=Add a value"
    sleep 2
    @selenium.type "value_set_element_value_attributes__name", "Yes"
    @selenium.type "document.forms[0].elements['value_set_element[value_attributes][][name]'][1]", "No"
    @selenium.type "document.forms[0].elements['value_set_element[value_attributes][][name]'][2]", "Maybe"
    @selenium.click "value_set_element_submit"
    sleep 2
    assert !@selenium.is_element_present("new-value-set-form")
    assert @selenium.is_text_present("Yes/No/Maybe")
    @selenium.click "link=Add value set"
    sleep 2
    assert @selenium.is_element_present("new-value-set-form")
    @selenium.type "value_set_element_name", "Yes/No"
    @selenium.click "link=Add a value"
    @selenium.click "link=Add a value"
    sleep 2
    @selenium.type "value_set_element_value_attributes__name", "Yes"
    @selenium.type "document.forms[0].elements['value_set_element[value_attributes][][name]'][1]", "No"
    @selenium.click "value_set_element_submit"
    sleep 2
    assert !@selenium.is_element_present("new-value-set-form")
    @selenium.click "link=Add value set"
    sleep 2
    assert @selenium.is_element_present("new-value-set-form")
    @selenium.type "value_set_element_name", "Yes/No"
    @selenium.click "link=Add a value"
    @selenium.click "link=Add a value"
    sleep 2
    @selenium.type "value_set_element_value_attributes__name", "Yes"
    @selenium.type "document.forms[0].elements['value_set_element[value_attributes][][name]'][1]", "No"
    @selenium.click "value_set_element_submit"
    sleep 2
    assert !@selenium.is_element_present("new-value-set-form")
    @selenium.click "link=Reorder questions"
    sleep 2
    assert_equal "false", @selenium.get_eval("nodes = window.document.getElementById(\"reorder-list\").childNodes; thirdItem =nodes[2].id.toString().substring(9); fourthItem =nodes[3].id.toString().substring(9); thirdItem > fourthItem")
    @selenium.drag_and_drop "//ul[@id='reorder-list']/li[4]", "0,-20"
    assert_equal "true", @selenium.get_eval("nodes = window.document.getElementById(\"reorder-list\").childNodes; thirdItem =nodes[2].id.toString().substring(9); fourthItem =nodes[3].id.toString().substring(9); thirdItem > fourthItem")
  end
end
