require File.dirname(__FILE__) + '/../../spec_helper'

describe "/answer_sets/edit.html.erb" do
  include AnswerSetsHelper
  
  before do
    @answer_set = mock_model(AnswerSet)
    @answer_set.stub!(:name).and_return("MyString")
    assigns[:answer_set] = @answer_set
  end

  it "should render edit form" do
    render "/answer_sets/edit.html.haml"
    
    response.should have_tag("form[action=#{answer_set_path(@answer_set)}][method=post]") do
      with_tag('input#answer_set_name[name=?]', "answer_set[name]")
    end
  end
end


