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
      response.should have_tag('span', :text => 'No tasks pending.')
    end

  end

  describe 'with user tasks' do

    before(:each) do
      treatment_category = mock('treatment category')
      treatment_category.should_receive(:code_description).at_least(1).times.and_return('Treatment')
      @values = {
        :name     => 'First task',
        :due_date => Date.today,
        :category => treatment_category,
        :priority => 'P1'}
      @task = mock(@values[:name])
      @values.each do |method, value|
        @task.should_receive(method).twice.and_return(value)
      end
      @tasks = [@task]
      assigns[:tasks] = @tasks
    end

    it 'should render tasks table on dashboard' do
      render 'dashboard/index.html.haml'
      response.should have_tag("h2", :text => 'Tasks')
      response.should have_tag("table")
    end

    it 'should have columns for name, date, priority, category' do
      render 'dashboard/index.html.haml'
      ['name', 'priority', 'due date', 'category'].each do |text|
        response.should have_tag("th", :text => text.capitalize)
      end
    end

    it 'should render field data for tasks' do
      render 'dashboard/index.html.haml'
      response.should have_tag("td", :text => l(@values.delete(:category)))
      response.should have_tag("td", :text => format_date(@values.delete(:due_date)))
      @values.each do |key, value|
        response.should have_tag("td", :text => value)        
      end
    end

  end
end
