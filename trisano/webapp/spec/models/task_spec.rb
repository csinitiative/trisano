require File.dirname(__FILE__) + '/../spec_helper'

describe Task do
  before(:each) do
    @task = Task.new
    @task.user_id = 1
    @task.name = "New task"
  end

  it "should be valid" do
    @task.should be_valid
  end

  it 'should produce an error if the name is too long' do
    @task.name = 's' * 256
    @task.should_not be_valid
    @task.errors.size.should == 1
    @task.errors.on(:name).should_not be_nil
  end
  
end
