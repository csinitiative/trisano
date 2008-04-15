require File.dirname(__FILE__) + '/../../spec_helper'

describe "/question_types/edit.html.erb" do
  include QuestionTypesHelper
  
  before do
    @question_type = mock_model(QuestionType)
    @question_type.stub!(:name).and_return("MyString")
    @question_type.stub!(:description).and_return("MyString")
    assigns[:question_type] = @question_type
  end

  it "should render edit form" do
    render "/question_types/edit.html.haml"
    
    response.should have_tag("form[action=#{question_type_path(@question_type)}][method=post]") do
      with_tag('input#question_type_name[name=?]', "question_type[name]")
      with_tag('input#question_type_description[name=?]', "question_type[description]")
    end
  end
end


