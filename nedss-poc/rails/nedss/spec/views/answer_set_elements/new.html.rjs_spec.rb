require File.dirname(__FILE__) + '/../../spec_helper'

describe "/answer_set_elements/new.rjs" do
  include QuestionsHelper
  
  before(:each) do
    @answer_set_element = mock_model(AnswerSetElement)
    @answer_set_element.stub!(:new_record?).and_return(true)
    @answer_set_element.stub!(:form_id).and_return("1")
    @answer_set_element.stub!(:name).and_return("MyString")
    @answer_set_element.stub!(:parent_element_id).and_return(4)
    assigns[:answer_set_element] = @answer_set_element
  end

  it "should render new form" do
    render "/answer_set_elements/new.rjs"
    
    response.should have_tag("form[action=?][method=post]", answer_set_elements_path) do
      with_tag("input#answer_set_element_name[name=?]", "answer_set_element[name]")
    end
  end
end
