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
end
