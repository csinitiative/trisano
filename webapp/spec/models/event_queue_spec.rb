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

describe EventQueue do
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

  it "should provide a text representation of the name and jurisdiction" do
    event_queue = Factory.create :event_queue, :queue_name => 'Enterics Group'
    event_queue.name_and_jurisdiction.should == ["Enterics Group", event_queue.jurisdiction.place.short_name].join(' - ')
  end

  it "names should be unique per the jurisdiction" do
    jurisdiction_ids = 2.times.map { create_jurisdiction_entity.id }
    EventQueue.create(:queue_name => 'My Queue', :jurisdiction_id => jurisdiction_ids.first).should be_valid
    EventQueue.create(:queue_name => 'My Queue', :jurisdiction_id => jurisdiction_ids.last).should be_valid
    EventQueue.create(:queue_name => 'My Queue', :jurisdiction_id => jurisdiction_ids.first).should_not be_valid
  end

  describe "deleting an event queue" do
    fixtures :event_queues, :users, :events, :participations, :entities, :people

    before(:each) do
      @user = users(:default_user)
      users(:admin_user).event_view_settings = {:diseases => true}
      users(:admin_user).save
      User.stubs(:current_user).returns(@user)
      event_queues(:enterics_queue).destroy
    end

    it "should remove the queue in all users' default index view settings" do
      User.find(:all, :conditions => "event_view_settings IS NOT NULL").each do |user|
        if user == @user
          user.event_view_settings[:queues].should be_empty
        else
          user.event_view_settings[:queues].should be_nil
        end
      end
    end

    describe "when event queue is in use" do
      fixtures :event_queues, :events, :users

      it "should remove the queue for existing entities" do
        events(:has_event_queue).event_queue_id.should be_nil
      end
    
      it "should reset event status if event is still in queue" do
        events(:has_event_queue).should be_accepted_by_lhd
      end
    end
  end

  describe "class methods" do
    describe "queues_for_jurisdictions" do

      fixtures :event_queues, :entities, :places, :places_types

      it "should return the event_queues associated with an array of jurisdictions" do
        EventQueue.queues_for_jurisdictions([event_queues(:joecool_queue).jurisdiction_id]).size.should == 1
        EventQueue.queues_for_jurisdictions([event_queues(:joecool_queue).jurisdiction_id]).first.queue_name.should == "JoeCool-UtahCounty"

        EventQueue.queues_for_jurisdictions([75]).size.should == 2
        EventQueue.queues_for_jurisdictions([75, 102]).size.should == 3

        EventQueue.queues_for_jurisdictions([99]).size.should == 0
        EventQueue.queues_for_jurisdictions([75, 102, 99]).size.should == 3
      end

    end
  end

end
