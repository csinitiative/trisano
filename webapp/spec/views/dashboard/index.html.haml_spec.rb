# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

  before(:each) do
    @assignees = []
    User.stubs(:default_task_assignees).returns(@assignees)
    @user = Factory.build(:user)
    @user.stubs(:id).returns(1)
    @user.stubs(:is_entitled_to_in?).returns(true)
    @jurisdictions = []
    @user.stubs(:jurisdictions_for_privilege).with(:approve_event_at_state).returns(@jurisdictions)
    User.stubs(:current_user).returns(@user)
  end

  describe 'without user tasks' do

    before(:each) do
      @user.stubs(:filter_tasks).returns([])
      @user.expects(:id).times(6).returns(1)
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
      @event = Factory.create(:morbidity_event)
      @jurisdiction = Factory.build(:jurisdiction, :secondary_entity_id => '1')
      @event.stubs(:all_jurisdictions).returns([@jurisdiction])

      @values = {
        :name          => 'First task',
        :due_date      => Date.today,
        :category_name => 'Treatment',
        :priority      => 'P1',
        :notes         => 'Sample notes',
        :user_name     => 'Default User',
        :status        => 'pending',
        :disease_name  => 'ATBF'}

      @task = Factory.build(:task)
      @task.stubs(:id).returns(1)
      @task.stubs(:event).returns(@event)
      @task.stubs(:user_id).returns(1)

      @tasks = [@task]
      @values.each do |method, value|
        @task.expects(method).at_least(2).returns(value)
      end
      @user.expects(:filter_tasks).returns(@tasks)
      @user.expects(:id).times(6).returns(1)
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
       %w(Description       notes),
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

    describe 'and with sort params' do

      %w(name due_date notes category_name priority user_name).each do |meth|
        it "should sort tasks by ##{meth}" do
          params[:tasks_ordered_by] = meth
          render 'dashboard/index.html.haml'
        end
      end

    end

    describe 'with no task filters' do
      it 'should have task_view_settings tag' do
        render 'dashboard/index.html.haml'
        response.should have_tag('#task_view_settings[style="display: none;"]')
      end

      it 'should have a link for changing settings' do
        render 'dashboard/index.html.haml'
        response.should have_tag("a[onclick*=Effect.toggle('task_view_settings')]")
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
        disease = Factory.build(:disease)
        disease.expects(:id).twice.returns('id')
        disease.expects(:disease_name).twice.returns('Sample Disease')
        Disease.expects(:find).with(:all, :order => 'disease_name').returns([disease])
        render 'dashboard/index.html.haml'
        response.should have_tag("label input[type=checkbox]")
        response.should have_tag("label", :text => /Sample Disease/)
      end

      it 'should have a list of user check boxes' do
        User.stubs(:default_task_assignees).returns([@user])
        @user.expects(:best_name).twice.returns('default_user')
        render 'dashboard/index.html.haml'
        response.should have_tag("label", :task => 'default_user') do
          with_tag("input[type=checkbox]")
        end
      end
          

      it 'should have a list of jurisdiction check boxes' do
        jurisdiction = Factory.build(:place)
        jurisdiction.expects(:name).twice.returns('some jurisdiction')
        @jurisdictions << jurisdiction
        render 'dashboard/index.html.haml'
        response.should have_tag("label", :task => 'some jurisdiction') do
          with_tag("input[type=checkbox]")
        end
      end
          
      it 'should have a list of task state check boxes' do
        render 'dashboard/index.html.haml'
        response.should have_tag("label", :task => 'Complete') do
          with_tag("input[type=checkbox]")
        end
      end

      it 'should have a submit button' do
        render 'dashboard/index.html.haml'
        response.should have_tag("input[type=submit]")
      end
    end

  end

  describe 'with nil field comparisons in user tasks' do
    before(:each) do
      @event = Factory.create(:morbidity_event)
      @jurisdiction = Factory.build(:jurisdiction, :secondary_entity_id => '1')
      @event.stubs(:all_jurisdictions).returns([@jurisdiction])

      @values = {
        :name          => 'First task',
        :due_date      => Date.today,
        :category_name => 'Treatment',
        :priority      => 'P1',
        :notes         => 'Sample notes',
        :user_name     => 'Default User',
        :status        => 'pending',
        :disease_name  => 'ATBF'}
      @nils   = {
        :name          => nil,
        :due_date      => nil,
        :category_name => nil,
        :priority      => nil,
        :notes         => nil,
        :user_name     => nil,
        :status        => nil,
        :disease_name  => nil}
      @task_values = Factory.build(:task)
      @task_nils   = Factory.build(:task)

      @task_values.stubs(:id).returns(1)
      @task_values.stubs(:status).returns('pending')
      @task_values.stubs(:event).returns(@event)
      @task_values.stubs(:user_id).returns(1)

      @task_nils.stubs(:id).returns(2)
      @task_nils.stubs(:status).returns('pending')
      @task_nils.stubs(:event).returns(@event)
      @task_nils.stubs(:user_id).returns(1)

      @tasks = [@task_values, @task_nils]
      @values.each do |method, value|
        @task_values.stubs(method).returns(value)
        @task_nils.stubs(method).returns(nil)
      end
      @user.stubs(:filter_tasks).returns(@tasks)
      @user.expects(:id).times(6).returns(1)
    end

    %w(name due_date notes category_name priority user_name).each do |meth|
      it "should handle nils when sorting by ##{meth}" do
        params[:tasks_ordered_by] = meth
        render 'dashboard/index.html.haml'
      end
    end

  end

end
