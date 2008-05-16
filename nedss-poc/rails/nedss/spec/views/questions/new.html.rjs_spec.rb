require File.dirname(__FILE__) + '/../../spec_helper'

describe "/questions/new.rjs" do
  include QuestionsHelper
  
  before(:each) do
    @question = mock_model(Question)
    @question.stub!(:new_record?).and_return(true)
    @question.stub!(:form_element_id).and_return("1")
    @question.stub!(:question_text).and_return("MyString")
    @question.stub!(:help_text).and_return("MyString")
    @question.stub!(:data_type).and_return("MyString")
    @question.stub!(:size).and_return("1")
    @question.stub!(:condition).and_return("MyString")
    @question.stub!(:display_as).and_return("MyString")
    @question.stub!(:is_on_short_form).and_return(false)
    @question.stub!(:is_required).and_return(false)
    @question.stub!(:is_exportable).and_return(false)
    @question.stub!(:parent_element_id).and_return(4)
    @question.stub!(:core_data).and_return("false")
    @question.stub!(:is_core_data).and_return(false)
    assigns[:question] = @question
  end

  it "should render new form" do
    render "/questions/new.rjs"
    
    response.should have_tag("form[action=?][method=post]", questions_path) do
      with_tag("input#question_question_text[name=?]", "question[question_text]")
#      with_tag("input#question_help_text[name=?]", "question[help_text]")
#      with_tag("input#question_data_type[name=?]", "question[data_type]")
#      with_tag("input#question_size[name=?]", "question[size]")
#      with_tag("input#question_condition[name=?]", "question[condition]")
#      with_tag("input#question_display_as[name=?]", "question[display_as]")
#      with_tag("input#question_is_on_short_form[name=?]", "question[is_on_short_form]")
#      with_tag("input#question_is_required[name=?]", "question[is_required]")
#      with_tag("input#question_is_exportable[name=?]", "question[is_exportable]")
    end
  end
end


