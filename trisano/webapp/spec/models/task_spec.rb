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

  describe 'working with categories' do
    fixtures :users

    it 'should return its category name' do
      @task.save.should_not be_nil
      @task.category_name.should be_nil
      category_code = ExternalCode.create({:code_name => 'task_category', :the_code => 'APT', :code_description => 'Appointment', :sort_order => '99'})
      @task.category = category_code
      @task.save.should_not be_nil
      @task.category_name.should eql("Appointment")
      @task.category_id.should eql(category_code.id)
    end
  end

  describe '#user_name' do
    fixtures :users

    it "should return the user's best name" do
      @task.user_name.should == 'Johnson'
    end
  
  end
      
end
