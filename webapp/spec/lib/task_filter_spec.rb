# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

require 'spec_helper'

describe TaskFilter do
  before :all do
    @user = Factory(:user)
  end

  before(:each) do
    User.current_user = @user
    @chicken_pox_event = Factory(:morbidity_event)
    @anthrax_event     = Factory(:morbidity_event)
  end

  def create_task(custom_settings={})
    event = custom_settings.delete(:event) || @chicken_pox_event
    user  = custom_settings.delete(:user)  || @user
    task = Task.new({:name => 'Do it',
                      :due_date => 1.day.from_now
                    }.merge(custom_settings))
    task.event = event
    task.user  = user
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
      @events = [Factory(:morbidity_event_with_disease), Factory(:morbidity_event_with_disease)]
      @disease_ids = @events.map { |e| e.disease_event.disease_id.to_s }
      @tasks = @events.map { |e| create_task(:event => e) }
    end

    it 'should only show tasks for disease that matches the filter' do
      tasks = @user.filter_tasks(:disease_filter => @disease_ids[0,1])
      tasks.should == @tasks[0,1]
    end
  end

  describe 'with user filter applied' do
    before(:each) do
      @user_one = Factory.create(:user)
      @user_two = Factory.create(:user)
      @user_three = Factory.create(:user)
      
      users = [@user_one, @user_two, @user_three]
      User.expects(:default_task_assignees).at_least(1).returns(users)
      @user_one_task   = create_task(:user => @user_one)
      @user_two_task   = create_task(:user => @user_two)
      @user_three_task = create_task(:user => @user_three)
      #now whack one to test user filtering
      users.pop
    end

    it 'should show tasks for only user ids in filter' do
      tasks = @user.filter_tasks(:users => [@user_one.id])
      tasks.include?(@user_one_task).should be_true
      tasks.size.should == 1

      tasks = @user.filter_tasks(:users => [@user_one.id, @user_two.id])
      tasks.include?(@user_one_task).should be_true
      tasks.include?(@user_two_task).should be_true
      tasks.size.should == 2
    end

    it 'should show tasks of users that can be assigned to by current user' do
      tasks = @user.filter_tasks(:users => [@user_one.id, @user_two.id, @user_three.id])
      tasks.include?(@user_one_task).should be_true
      tasks.include?(@user_two_task).should be_true
      tasks.size.should == 2
    end
  end

  describe 'with jurisdiction filter applied' do

    before(:each) do
      @events = [Factory(:morbidity_event), Factory(:morbidity_event)]
      @jurisdictions = @events.map { |e| e.jurisdiction.secondary_entity.place }
      @tasks = [create_task(:event => @events.first), create_task(:event => @events.second)]
    end

    it 'should show all tasks in filtered jurisdictions' do
      @user.expects(:jurisdictions_for_privilege).with(:approve_event_at_state).returns(@jurisdictions)
      tasks = @user.filter_tasks(:jurisdictions => @jurisdictions.map(&:id))
      tasks.sort_by(&:id).should == @tasks.sort_by(&:id)
    end

    it 'should only show tasks in jurisdictions the current user has state approval rights' do
      @user.expects(:jurisdictions_for_privilege).with(:approve_event_at_state).returns([@jurisdictions.first])
      tasks = @user.filter_tasks(:jurisdictions => @jurisdictions.map(&:id))
      tasks.should == @tasks[0,1]
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

  describe 'event filters' do

    before(:each) do
      create_task(:event => @chicken_pox_event)
      create_task(:event => @chicken_pox_event, :name => 'Done it', :due_date => 1.day.ago)
      create_task(:event => @anthrax_event, :name => 'Ignore it')
    end

    it 'should show only tasks associated with event' do
      names = @chicken_pox_event.filter_tasks.collect(&:name)
      names.include?('Done it').should be_true
      names.include?('Do it').should be_true
      names.include?('Ignore it').should_not be_true
      names.size.should == 2
    end

  end
end

