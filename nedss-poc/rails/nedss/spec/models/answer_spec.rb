require File.dirname(__FILE__) + '/../spec_helper'

describe Answer do
  
  before(:each) do 
    question = Question.new :short_name => 'short_name_01'
    @answer = Answer.new :question => question    
  end

  it "should return the short name from the question" do
    @answer.short_name.should == 'short_name_01'
  end

end
