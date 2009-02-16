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
      @user = mock('current user')
      @user.stub!(:tasks).and_return([])
      User.stub!(:current_user).and_return(@user)
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
      @values = {
        :name          => 'First task',
        :due_date      => Date.today,
        :category_name => 'Treatment',
        :priority      => 'P1',
        :notes         => 'Sample notes',
        :user_name     => 'Default User'}
      @task = mock(@values[:name])
      @tasks = [@task]
      @values.each do |method, value|
        @task.should_receive(method).at_least(2).times.and_return(value)
      end
      @user = mock('user')
      @user.should_receive(:tasks).and_return(@tasks)
      User.should_receive(:current_user).and_return(@user)
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
        response.should have_tag("th") do
          with_tag("a[onclick*=tasks_ordered_by=#{order_by}]")
          with_tag("a", :text => text)
        end
      end
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

  end
end
