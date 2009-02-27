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

describe TaskFilter do
  fixtures :diseases, :users, :events, :disease_events, :participations, :entities, :places

  before(:each) do
    @user = User.find(1)
    User.stub!(:current_user).and_return(@user)
    @chicken_pox_event = Event.find(1)
    @anthrax_event     = Event.find(5)
  end

  def create_task(custom_settings={})
    event = custom_settings.delete(:event) || @chicken_pox_event
    user  = custom_settings.delete(:user)  || @user
    task = Task.new({:name => 'Do it',
                      :due_date => 1.day.from_now
                    }.merge(custom_settings))
    task.event = event
    task.user =  user
    task.save!
    yield(event, task) if block_given?
    task
  end

  describe 'filtering tasks by days' do
    describe 'with only look ahead set' do
      it 'should show future tasks that fall within filter' do
        create_task do |event, task|
          tasks = event.filter_tasks({:look_ahead => '1'})
          tasks.size.should == 1
        end
      end

      it 'should not show future tasks that fall outside the filter' do
        create_task(:due_date => 3.days.from_now) do |event, task|
          tasks = event.filter_tasks({:look_ahead => '1'})
          tasks.size.should == 0
        end
      end

      it 'should show today\'s tasks if look_ahead is set to zero' do
        create_task(:due_date => 0.days.from_now) do |event, task|
          event.filter_tasks(:look_ahead => '0').size.should == 1
        end
      end

      it 'should show all old tasks if look_back is not set' do
        create_task(:due_date => 1.day.ago) do |event, task|
          event.filter_tasks(:look_ahead => '1').size.should == 1
        end
      end

    end
    
    describe 'with only look back set' do
      it 'should show old tasks that fall within the filter' do
        create_task(:due_date => 1.day.ago) do |event, task|
          event.filter_tasks(:look_back => '3').size.should == 1
        end
      end
      
      it 'should not show old tasks that fall outside the filter' do
        create_task(:due_date => 3.days.ago) do |event, task|
          event.filter_tasks(:look_back => '1').size.should == 0
        end
      end

    end

    describe 'with look ahead and look back set' do
      it 'should show tasks between ends of filter' do
        create_task(:due_date => 0.days.from_now) do |event, task|
          event.filter_tasks(:look_back => '1', :look_ahead => '1').size.should == 1
        end
      end

      it 'should not show tasks too far in the future' do
        create_task(:due_date => 2.days.from_now) do |event, task|
          event.filter_tasks(:look_back => '1', :look_ahead => '1').size.should == 0
        end
      end

      it 'should not show tasks too far in the past' do
        create_task(:due_date => 2.days.ago) do |event, task|
          event.filter_tasks(:look_back => '1', :look_ahead => '1').size.should == 0
        end
      end

    end

  end  

  describe 'with no disease filter applied' do
    before(:each) do
      create_task(:event => @chicken_pox_event)
      create_task(:event => @anthrax_event)
    end

    it 'should show tasks for all diseases' do
      @user.filter_tasks.size.should == 2
    end
 
  end

  describe 'with disease filter applied' do
    before(:each) do
      @chicken_pox_task = create_task(:event => @chicken_pox_event)
      @anthrax_task     = create_task(:event => @anthrax_event)
    end

    it 'should only show tasks for disease that matches the filter' do
      tasks = @user.filter_tasks(:disease_filter => ['1'])
      tasks.pop.should == @chicken_pox_task
      tasks.should be_empty
    end
  end

  describe 'with user filter applied' do
    before(:each) do
      #need all users for assignment
      users = [User.find(1), User.find(2), User.find(3)]
      User.should_receive(:default_task_assignees).at_least(1).times.and_return(users)
      @user_one_task   = create_task(:user => users[0])
      @user_two_task   = create_task(:user => users[1])
      @user_three_task = create_task(:user => users[2])
      #now whack one to test user filtering
      users.pop
    end

    it 'should show tasks for only user ids in filter' do
      tasks = @user.filter_tasks(:users => ['1'])
      tasks.include?(@user_one_task).should be_true
      tasks.size.should == 1

      tasks = @user.filter_tasks(:users => ['1', '2'])
      tasks.include?(@user_one_task).should be_true
      tasks.include?(@user_two_task).should be_true
      tasks.size.should == 2
    end
    
    it 'should show tasks of users that can be assigned to by current user' do
      tasks = @user.filter_tasks(:users => ['1', '2', '3'])
      tasks.include?(@user_one_task).should be_true
      tasks.include?(@user_two_task).should be_true
      tasks.size.should == 2
    end      
  end

  describe 'with jurisdiction filter applied' do

    before(:each) do
      @jurisdiction_one = mock('jurisdiction 1')
      @jurisdiction_one.should_receive(:id).and_return(73)
      User.current_user.stub!(:jurisdictions_for_privilege).with(:assign_task_to_user).and_return([])
      @jurisdiction_one_task = create_task(:event => @chicken_pox_event)
      @jurisdiction_two_task = create_task(:event => Event.find(1001))
    end

    it 'should show all tasks in filtered jurisdictions' do
      jurisdiction_two = mock('jurisdiction 2')
      jurisdiction_two.should_receive(:id).and_return(101)
      User.current_user.should_receive(:jurisdictions_for_privilege).with(:approve_event_at_state).and_return([@jurisdiction_one, jurisdiction_two])
      tasks = @user.filter_tasks(:jurisdictions => ['73', '101'])
      tasks.include?(@jurisdiction_one_task).should be_true
      tasks.include?(@jurisdiction_two_task).should be_true
      tasks.size.should == 2
    end

    it 'should only show tasks in jurisdictions the current user has state approval rights' do
      User.current_user.should_receive(:jurisdictions_for_privilege).with(:approve_event_at_state).and_return([@jurisdiction_one])
      tasks = @user.filter_tasks(:jurisdictions => ['73', '101'])
      tasks.pop.should == @jurisdiction_one_task
      tasks.should be_empty
    end
  end

  describe 'task status filter applied' do
    before(:each) do
      @completed_task = create_task
      @completed_task.update_attribute(:status, 'complete')
      @na_task        = create_task
      @na_task.update_attribute(:status, 'not_applicable')
      @pending_task   = create_task      
    end
    
    it 'should exclude completed tasks' do
      tasks = @user.filter_tasks(:task_statuses => ['pending', 'not_applicable'])
      tasks.include?(@na_task).should be_true
      tasks.include?(@pending_task).should be_true
      tasks.include?(@completed_task).should_not be_true
      tasks.size.should == 2
    end
      
    it 'should exclude N/A tasks' do
      tasks = @user.filter_tasks(:task_statuses => ['pending', 'complete'])
      tasks.include?(@na_task).should_not be_true
      tasks.include?(@pending_task).should be_true
      tasks.include?(@completed_task).should be_true
      tasks.size.should == 2
    end

    it 'should default to showing all tasks' do
      tasks = @user.filter_tasks
      tasks.include?(@na_task).should be_true
      tasks.include?(@pending_task).should be_true
      tasks.include?(@completed_task).should be_true
      tasks.size.should == 3
    end
  end

end

