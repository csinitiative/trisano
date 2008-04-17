require File.dirname(__FILE__) + '/../../spec_helper'

describe "/question_types/new.html.erb" do
  include QuestionTypesHelper
  
  before(:each) do
    @question_type = mock_model(QuestionType)
    @question_type.stub!(:new_record?).and_return(true)
    @question_type.stub!(:name).and_return("MyString")
    @question_type.stub!(:description).and_return("MyString")
    @question_type.stub!(:html_form_type).and_return("input-text")
    assigns[:question_type] = @question_type
  end

  it "should render new form" do
    render "/question_types/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", question_types_path) do
      with_tag("input#question_type_name[name=?]", "question_type[name]")
      with_tag("input#question_type_description[name=?]", "question_type[description]")
    end
  end
end


