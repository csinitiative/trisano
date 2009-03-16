# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

require File.dirname(__FILE__) + '/../spec_helper'

describe Task do
  fixtures :users, :role_memberships, :roles, :entities, :privileges, :privileges_roles, :entitlements

  before(:each) do
    mock_user
    @task = Task.new
    @task.user_id = 1
    @task.due_date = 1.day.from_now
    @task.name = "New task"
  end

  it "should be valid" do
    @task.should be_valid
  end
  
  it 'should not be valid with out a due date' do
    @task.due_date = nil
    @task.should_not be_valid
  end

  it "should be in pending status after initial creation" do
    @task.save!
    @task.status.should == 'pending'
  end

  it 'should produce an error if the name is too long' do
    @task.name = 's' * 256
    @task.should_not be_valid
    @task.errors.on(:name).should_not be_nil
  end

  it 'should not allow an update with an invalid status' do
    @task.save!
    @task.status = 'not_a_real_status'
    @task.save.should be_false
    @task.errors.on(:status).should_not be_nil
  end

  it 'should allow updates with valid statuses' do
    @task.save!
    Task.valid_statuses.each do |status|
      @task.status = status
      @task.save.should be_true
    end
  end

  describe 'working with categories' do
    
    it 'should return its category name' do
      mock_user
      @task.save.should_not be_nil
      @task.category_name.should be_nil
      category_code = ExternalCode.create({:code_name => 'task_category', :the_code => 'APT', :code_description => 'Appointment', :sort_order => '99'})
      @task.category = category_code
      @task.save.should_not be_nil
      @task.category_name.should eql("Appointment")
      @task.category_id.should eql(category_code.id)
    end
  end

  describe 'working with task assignment' do

    before(:each) do
      @user = users(:default_user)
      User.stub!(:current_user).and_return(@user)
    end

    it 'should allow assignment to self' do
      @task.save.should be_true
    end

    it 'should allow assignment to a user with the update_cmr privilege' do
      @assignees = mock('assignees')
      @assignees.should_receive(:id).and_return(3)
      User.stub!(:default_task_assignees).and_return([@assignees])
      @task.user_id = users(:update_cmr_user).id      
      @task.save!
    end

    it 'should not allow assignment to a user with the view_cmr privilege' do
      @task.user_id = users(:view_cmr_user).id
      @task.save.should be_false
      @task.errors.size.should == 1
    end

    it 'should not allow assignment to a user with the update_cmr privilege in another jurisdiction' do
      @task.user_id = users(:update_davis_user).id
      @task.save.should be_false
      @task.errors.size.should == 1
    end

    it 'should not allow assignment to others if the assigner does not have assign_task_to_user privs' do
      User.stub!(:current_user).and_return(users(:admin_user))
      @task.user_id = users(:update_cmr_user).id
      @task.save.should be_false
    end

    it 'should allow assignment to self if the assigner does not have assign_task_to_user privs' do
      User.stub!(:current_user).and_return(users(:admin_user))
      @task.user_id = users(:admin_user).id
      @task.save.should be_true
    end
    
  end

  describe 'generating notes' do
    
    before(:each) do
      @event_hash = {
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Green"
            }
          }
        }
      }

      @event = MorbidityEvent.new(@event_hash)
    end

    it 'should create a clinical note on the event when creating a task with the notes populated' do
      @event.save.should be_true
      @event.notes.size.should == 0
      @task.event = @event
      @task.notes = "This is a note on a task."
      @task.save.should be_true
      @event.notes.size.should == 1
      @event.notes.first.note.should == "Task created.\n\nName: New task\nDescription: This is a note on a task."
    end

    it 'should not create a clinical note on the event when creating a task with the notes unpopulated' do
      @event.save.should be_true
      @event.notes.size.should == 0
      @task.event = @event
      @task.save.should be_true
      @event.notes.size.should == 0
    end
    
    it 'should create a clinical note on the event when updating a task with a status change' do
      @event.save.should be_true
      @task.event = @event
      @task.save.should be_true
      @task.status = "complete"
      @task.save.should be_true
      @event.notes.size.should == 1
      @event.notes.first.note.should == "Task status change.\n\n'New task' changed from Pending to Complete"
    end

    it 'should not create a clinical note on the event when updating a task without a status change' do
      @event.save.should be_true
      @task.event = @event
      @task.save.should be_true
      @task.name = "Name change only"
      @task.save.should be_true
      @event.notes.size.should == 0
    end
    
  end

  describe '#user_name' do
    fixtures :users

    it "should return the user's best name" do
      @task.user_name.should == 'Johnson'
    end
  
  end
      
end
