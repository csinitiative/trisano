# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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
  before(:each) do
    @task = Factory(:task)
  end

  it "should be valid" do
    @task.should be_valid
  end

  it 'should not be valid without a due date' do
    @task.due_date = nil
    @task.should_not be_valid
  end

  it 'should not be valid with a due date more than 2 years from now' do
    @task.due_date = (2.years.from_now) + 1.day
    @task.save
    @task.errors.on(:due_date).should == "must fall within the next two years"
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
    @task.errors.on(:status).should == "is not valid"
  end

  it 'should allow updates with valid statuses' do
    @task.save!
    Task.valid_statuses.each do |status|
      @task.status = status
      @task.save.should be_true
    end
  end

  it 'should not allow an update with an invalid priority' do
    @task.save!
    @task.priority = 'not_a_real_priority'
    @task.save.should be_false
    @task.errors.on(:priority).should == "is not valid"
  end

  it 'should allow updates with valid priorities' do
    @task.save!
    Task.valid_priorities.each do |priority|
      @task.priority = priority
      @task.save.should be_true
    end
  end

  describe 'working with categories' do

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
end

describe Task, 'when working with task assignment' do
  before(:each) do
    @user = Factory(:privileged_user)
    add_privileges_for(@user,"assign_task_to_user")
    @task = Factory(:task, :user => @user)
  end

  it 'should allow assignment to self' do
    @task.save.should be_true
  end

  it 'should allow assignment to a user with the update_event privilege' do
    @assignee = Factory(:privileged_user)
    add_privileges_for(@assignee, "update_event")

    User.current_user = @user

    @task.update_attributes(:user => @assignee)
    @task.should be_valid
    @task.user.should == @assignee
  end

  it 'should not allow assignment to a user with the view_event privilege' do
    @assignee = Factory(:privileged_user)
    add_privileges_for(@assignee, "view_event")

    User.current_user = @user

    @task.user = @assignee
    @task.save.should be_false
    @task.errors.on(:base).should == "Insufficient privileges for task assignment."
    @task.errors.size.should == 1
  end

  it 'should not allow assignment to a user with the update_event privilege in another jurisdiction' do
    @assignee = Factory(:privileged_user)
    add_privileges_for(@assignee, "update_event")
    @assignee.role_memberships.first.update_attributes(:jurisdiction => Factory(:jurisdiction).place_entity)
    User.current_user = @user

    @task.user = @assignee

    @task.save.should be_false
    @task.errors.on(:base).should == "Insufficient privileges for task assignment."
    @task.errors.size.should == 1
  end

  it 'should not allow assignment to others if the assigner does not have assign_task_to_user privs' do
    remove_privileges_for(@user, "assign_task_to_user")
    @assignee = Factory(:privileged_user)
    User.current_user = @user
    @task.user = @assignee

    @task.save.should be_false
    @task.errors.on(:base).should == "Insufficient privileges for task assignment."
  end

  it 'should allow assignment to others if the assigner does not have assign_task_to_user privs, if the task is system generated' do
    remove_privileges_for(@user, "assign_task_to_user")
    @assignee = Factory(:privileged_user)
    User.current_user = @user
    @task.user = @assignee
    @task.system_generated = true

    @task.save.should be_true
    @task.errors.on(:base).should be_nil
  end

  it 'should allow assignment to self if the assigner does not have assign_task_to_user privs' do
    remove_privileges_for(@user, "assign_task_to_user")
    @task.user = @user
    @task.save.should be_true
  end

  it "should return the user's best name" do
    @user = Factory(:user)
    @task.update_attributes(:user => @user)
    @task.user_name.should == @user.user_name
  end

end

describe Task, 'generating notes' do
  before(:each) do
    @task = Factory.build(:task)
    @event = Factory(:morbidity_event)
    @task.event = @event
  end

  it 'should create a clinical note on the event when creating a task with the notes populated' do
    @event.notes.size.should == 0
    @task.notes = "This is a note on a task."
    @task.save.should be_true
    @event.save.should be_true
    @event.notes.size.should == 1
    @event.notes.first.note.should == "Task created.\n\nName: #{@task.name}\nDescription: This is a note on a task."
  end

  it 'should not create a clinical note on the event when creating a task with the notes unpopulated' do
    @event.notes.size.should == 0
    @task.save.should be_true
    @event.notes.size.should == 0
  end

  it 'should create a clinical note on the event when updating a task with a status change' do
    @task.save.should be_true
    @task.status = "complete"
    @task.save.should be_true
    @event.notes.size.should == 1
    @event.notes.first.note.should == "Task status change.\n\n'#{@task.name}' changed from Pending to Complete."
  end

  it 'should not create a clinical note on the event when updating a task without a status change' do
    @task.save.should be_true
    @task.name = "Name change only"
    @task.save.should be_true
    @event.notes.size.should == 0
  end
end

describe Task, 'with repeating tasks' do
  before(:each) do
    @task = Factory.build(:task)
  end

  it 'should not accept an interval without an until' do
    @task.repeating_interval = :year
    @task.save.should be_false
    @task.errors[:base].should == "A repeating task requires an interval and an until date."
  end

  it 'should not accept an until without an interval' do
    @task.until_date = 2.years.from_now
    @task.save.should be_false
    @task.errors[:base].should == "A repeating task requires an interval and an until date."
  end

  it 'should allow creation with valid intervals' do
    @task.until_date = 1.week.from_now
    Task.valid_intervals.each do |interval|
      @task.repeating_interval = interval
      @task.save.should be_true
    end
  end

  it 'should not allow creation with an invalid interval' do
    @task.until_date = 1.week.from_now
    @task.repeating_interval = :oh_sometimes
    @task.save.should be_false
    @task.errors[:repeating_interval].should == "The task interval is invalid"
  end

  it 'should not allow creation with an until date that comes after the original task due date' do
    @task.until_date = 1.week.ago
    @task.repeating_interval = :week
    @task.save.should be_false
    @task.errors[:until_date].should == "date must come after the original due date"
  end

  it 'should establish repeating tasks if all required repeating task attributes are present' do
    @task.repeating_interval = :week
    @task.until_date = 2.years.from_now
    @task.save.should be_true
    @task.repeating_tasks.size.should > 0
    @task.repeating_task_id.should eql(@task.id)
  end

  it 'should accept a daily interval until two years from now' do
    @task.repeating_interval = :day
    @task.until_date = 2.years.from_now.to_date
    @task.save.should be_true
    @task.repeating_tasks.size.should >= 729
    @task.repeating_tasks.size.should <= 731
  end

  it 'should accept a weekly interval until two years from now' do
    @task.repeating_interval = :week
    @task.until_date = 2.years.from_now
    @task.save.should be_true
    @task.repeating_tasks.size.should == 105
  end

  it 'should accept a monthly interval until two years from now' do
    @task.repeating_interval = :month
    @task.until_date = 2.years.from_now
    @task.save.should be_true
    (24..25).include?(@task.repeating_tasks.size).should be_true
  end

  it 'should accept a yearly interval until two years from now' do
    @task.repeating_interval = :year
    @task.until_date = 2.years.from_now
    @task.save.should be_true
    @task.repeating_tasks.size.should == 2
  end

  it 'should not accept a daily interval until more than two years from now' do
    @task.repeating_interval = :day
    @task.until_date = (2.years.from_now) + 1.day
    @task.save.should be_false
    @task.errors[:until_date].should == "date must fall within the next two years"
  end

  it 'should not accept a weekly interval until more than two years from now' do
    @task.repeating_interval = :week
    @task.until_date = (2.years.from_now) + 1.day
    @task.save.should be_false
    @task.errors[:until_date].should_not be_nil
  end

  it 'should not accept a monthly interval until more than two years from now' do
    @task.repeating_interval = :month
    @task.until_date = (2.years.from_now) + 1.day
    @task.save.should be_false
    @task.errors[:until_date].should_not be_nil
  end

  it 'should not accept a yearly interval until more than two years from now' do
    @task.repeating_interval = :year
    @task.until_date = (2.years.from_now) + 1.day
    @task.save.should be_false
    @task.errors[:until_date].should_not be_nil
  end

  it 'should only create one clinical note for all tasks added' do
    @event = Factory(:morbidity_event)
    @event.notes.size.should == 0
    @task.event = @event
    @task.notes = "This is a note on a task."
    @task.repeating_interval = :year
    @task.until_date = (2.years.from_now)
    @task.save.should be_true
    @event.notes.size.should == 1
    @event.notes.first.note.include?("Repeats every #{@task.repeating_interval.to_s.downcase} until #{@task.until_date.to_s}").should be_true
  end
end

