# Copyright (C) 2007, 2008, The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the terms of the
# GNU Affero General Public License as published by the Free Software Foundation, either 
# version 3 of the License, or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
# See the GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License along with TriSano. 
# If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

require File.dirname(__FILE__) + '/../spec_helper'

describe EventQueue do
  before(:each) do
  end

  it "should be valid with queue name and jurisdiction" do
    @event_queue = EventQueue.new( :queue_name => 'Enterics', :jurisdiction_id => 1 )
    @event_queue.should be_valid
  end

  it "should not be valid if queue name not provided" do
    @event_queue = EventQueue.new( :jurisdiction_id => 1 )
    @event_queue.should_not be_valid
  end

  it "should not be valid if jurisdiction not provided" do
    @event_queue = EventQueue.new( :queue_name => 'Enterics' )
    @event_queue.should_not be_valid
  end

  fixtures :event_queues, :entities, :places

  it "should be associated with a jurisdiction" do
    event_queues(:enterics_queue).jurisdiction.current_place.name.should == "Southeastern District"
  end

  # Just one test here for the before_save.  Underscore method tested in lib/utilities_spec.rb
  it "should append short jurisidction name to queue name, remove surrounding whitespace, and replace internal whitespace with underscores" do
    @event_queue = EventQueue.new( :queue_name => 'Enterics Group', :jurisdiction_id => 102 )
    @event_queue.save
    @event_queue.queue_name.should == "Enterics_Group-Davis_County"
  end

end
