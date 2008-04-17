require File.dirname(__FILE__) + '/../../spec_helper'

describe "/answer_sets/new.html.erb" do
  include AnswerSetsHelper
  
  before(:each) do
    @answer_set = mock_model(AnswerSet)
    @answer_set.stub!(:new_record?).and_return(true)
    @answer_set.stub!(:name).and_return("MyString")
    assigns[:answer_set] = @answer_set
  end

  it "should render new form" do
    render "/answer_sets/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", answer_sets_path) do
      with_tag("input#answer_set_name[name=?]", "answer_set[name]")
    end
  end
end


