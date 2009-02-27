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

require File.dirname(__FILE__) + '/../../spec_helper'

include ApplicationHelper

describe "/dashboard/index.html.haml" do
  
  describe 'without user tasks' do

    before(:each) do
      # All the ordinary mocks had to be made into mock models to provide the right whatnots to
      # Rails 2.3 and Rspec 1.1.12.  Things like to_param I imagine, for constucting URLs.
      # @user = mock('current user')
      @user = mock_model(User)
      @user.stub!(:filter_tasks).and_return([])
      @user.should_receive(:id).exactly(6).times.and_return(1)
      User.stub!(:current_user).and_return(@user)
      @controller.template.should_receive(:task_filter_description).with(params).and_return('Task filter message')
    end
    
    it 'should not render the table' do
      render 'dashboard/index.html.haml'
      response.should_not have_tag('table')
    end

    it 'should have tasks header' do
      render 'dashboard/index.html.haml'
      response.should have_tag('h2', :text => 'Tasks')
    end
                             
    it 'should have a "no tasks" message' do
      render 'dashboard/index.html.haml'
      response.should have_tag('span', :text => 'No tasks')
    end

  end

  describe 'with user tasks' do

    before(:each) do
      # @event = mock('event')
      @event = mock_model(Event)
      
      @values = {
        :name          => 'First task',
        :due_date      => Date.today,
        :category_name => 'Treatment',
        :priority      => 'P1',
        :notes         => 'Sample notes',
        :user_name     => 'Default User'}

      # @task = mock(@values[:name])
      @task = mock_model(Task)
      @task.stub!(:id).and_return(1)
      @task.stub!(:status).and_return('pending')
      @task.stub!(:event).and_return(@event)
      @task.should_receive(:user_id).and_return(1)
      
      @tasks = [@task]
      @values.each do |method, value|
        @task.should_receive(method).at_least(2).times.and_return(value)
      end
      #@user = mock('user')
      @user = mock_model(User)
      @user.should_receive(:filter_tasks).and_return(@tasks)
      @user.should_receive(:id).exactly(6).times.and_return(1)
      User.should_receive(:current_user).and_return(@user)
      @controller.template.should_receive(:task_filter_description).with(params).and_return('Task filter message')
      params[:look_back] = '0'
      params[:look_ahead] = '0'
      params['task'] = {'status' => 'complete'}
    end

    it 'should render tasks table on dashboard' do
      render 'dashboard/index.html.haml'
      response.should have_tag("h2", :text => 'Tasks')
      response.should have_tag("table")
    end

    it 'should have columns for name, date, priority, category' do
      render 'dashboard/index.html.haml'
      [%w(Name              name),
        %w(Notes             notes),
        %w(Priority          priority),
        %w(Due&nbsp;date     due_date),
        %w(Category          category_name),
        %w(Assigned&nbsp;to  user_name)].each do |text, order_by|
        response.should have_tag("th a[onclick*=tasks_ordered_by=#{order_by}]", :text => text)
        response.should have_tag("th a[onclick*=look_back=0]", :text => text)
      end
    end

    it 'should have controls that contain sorting and filtering params' do
      render 'dashboard/index.html.haml'
      response.should have_tag("td select[onchange*=look_back=0]")
      response.should have_tag("td select[onchange*=look_ahead=0]")
      response.should have_tag("td select[onchange*=look_back=0]")
      response.should have_tag("td select[onchange*=look_ahead=0]")
      response.should_not have_tag("td select[onchange*=complete]")
    end

    it 'should render field data for tasks' do
      render 'dashboard/index.html.haml'
      @values.each do |key, value|
        response.should have_tag("td", :text => value)        
      end
      response.should have_tag("td", :text => 'Default User')
    end

    describe 'and with sort params' do
      
      %w(name due_date notes category_name priority user_name).each do |meth|
        it "should sort tasks by ##{meth}" do
          params[:tasks_ordered_by] = meth
          render 'dashboard/index.html.haml'
        end
      end

    end

    describe 'with no task filters' do
      it 'should show the \'no filters\' message' do
        render 'dashboard/index.html.haml'
        response.should have_tag('span', :text => 'Task filter message')
      end
      
      it 'should have task_view_settings tag' do
        render 'dashboard/index.html.haml'
        response.should have_tag('#task_view_settings[style="display: none;"]')
      end

      it 'should have a link for changing settings' do
        render 'dashboard/index.html.haml'
        response.should have_tag("a[onclick*=Effect.BlindDown('task_view_settings')]")
      end 
    end

    describe 'task filter form' do
      it 'should have a settings update form' do
        render 'dashboard/index.html.haml'
        response.should have_tag("form[action=/]")
      end

      it 'should have a field for looking back' do
        render 'dashboard/index.html.haml'
        response.should have_tag("input#look_back")
      end

      it 'should have a field for looking ahead' do 
        render 'dashboard/index.html.haml'
        response.should have_tag("input#look_ahead")
      end

      it 'should have a disease filter label' do
        render 'dashboard/index.html.haml'
        response.should have_tag("label", :text => 'Disease Filter')
      end

      it 'should have a list of disease check boxes' do
        # disease = mock('disease')
        disease = mock_model(Disease)
        disease.should_receive(:id).twice.and_return('id')
        disease.should_receive(:disease_name).twice.and_return('Sample Disease')
        Disease.should_receive(:find).with(:all).and_return([disease])
        render 'dashboard/index.html.haml'
        response.should have_tag("label input[type=checkbox]")
        response.should have_tag("label", :text => /Sample Disease/)
      end

      it 'should have a submit button' do
        render 'dashboard/index.html.haml'
        response.should have_tag("input[type=submit]")
      end
    end

  end

  describe 'with nil field comparisons in user tasks' do
    before(:each) do
      # @event = mock('event')
      @event = mock_model(Event)
      
      @values = {
        :name          => 'First task',
        :due_date      => Date.today,
        :category_name => 'Treatment',
        :priority      => 'P1',
        :notes         => 'Sample notes',
        :user_name     => 'Default User'}
      @nils   = {
        :name          => nil,
        :due_date      => nil,
        :category_name => nil,
        :priority      => nil,
        :notes         => nil,
        :user_name     => nil}
      # @task_values = mock(@values[:name])
      @task_values = mock_model(Task)
      # @task_nils   = mock('nil task')
      @task_nils   = mock_model(Task)

      @task_values.stub!(:id).and_return(1)
      @task_values.stub!(:status).and_return('pending')
      @task_values.stub!(:event).and_return(@event)
      @task_values.should_receive(:user_id).and_return(1)

      @task_nils.stub!(:id).and_return(2)
      @task_nils.stub!(:status).and_return('pending')
      @task_nils.stub!(:event).and_return(@event)
      @task_nils.should_receive(:user_id).and_return(1)

      @tasks = [@task_values, @task_nils]
      @values.each do |method, value|
        @task_values.stub!(method).and_return(value)
        @task_nils.stub!(method).and_return(nil)
      end
      # @user = mock('user')
      @user = mock_model(User)
      @user.should_receive(:filter_tasks).and_return(@tasks)      
      @user.should_receive(:id).exactly(6).times.and_return(1)
      User.should_receive(:current_user).and_return(@user)      
      @controller.template.should_receive(:task_filter_description).with(params).and_return('Task filter message')
    end

    %w(name due_date notes category_name priority user_name).each do |meth|
      it "should handle nils when sorting by ##{meth}" do
        params[:tasks_ordered_by] = meth
        render 'dashboard/index.html.haml'
      end
    end

  end

end
