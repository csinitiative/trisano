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

describe DashboardHelper, "#task_filter_description" do
  
  describe 'when no filters applied' do
    it 'should show no filters applied' do
      helper.task_filter_description({}).should == 'Showing all tasks.'
    end
  end
  describe 'when look ahead filter applied' do
    it 'should show the number of days looking ahead' do
      helper.task_filter_description(:look_ahead => '3').should == "Showing all tasks through #{Date.today + 3}."
    end

    it 'should use \'tomorrow\' if looking ahead one day' do
      helper.task_filter_description(:look_ahead => '1').should == 'Showing all tasks through tomorrow.'
    end
  end

  describe 'when look back filter applied' do
    it 'should show the number of days looking back' do
      helper.task_filter_description(:look_back => '3').should == "Showing all tasks starting from #{Date.today - 3}."
    end

    it 'should use \'yesterday\' if looking back one day' do
      helper.task_filter_description(:look_back => '1').should == 'Showing all tasks starting from yesterday.'
    end
  end

  describe 'when look ahead and look back filters applied' do
    it 'should combine descriptions' do
      helper.task_filter_description(:look_back => '1', :look_ahead => '1').should == 'Showing all tasks starting from yesterday through tomorrow.'
    end
  end

  describe 'when look ahead and look back are both zero' do
    it 'should just show today' do
      helper.task_filter_description(:look_back => '0', :look_ahead => '0').should == 'Showing all tasks for today.'
    end
  end
end
