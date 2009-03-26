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

describe Routing::Workflow do

  before :all do
    class RoutingExample
      include Routing::Workflow
      workflow
    end
  end

  it "should respond to :workflow" do
    RoutingExample.respond_to?(:workflow).should be_true
  end

  it "workflow should initialize class states" do
    RoutingExample.states.should_not be_nil
    RoutingExample.ordered_states.should_not be_nil
  end

  describe 'building states' do
    before :each do
      class StateBuildingExample
        include Routing::Workflow
        workflow do
          state :new do |s|
            s.transitions = [:next]
            s.required_privilege = :create_event
            s.description = 'New'
            s.state_code = "NEW"
            s.note_text = 'This is some note text'
          end
          state :next do |s|
            s.transitions = [:new, :last]
            s.action_phrase = 'Moving on'
            s.required_privilege = :promote_event
            s.description = 'Next'
            s.state_code  = "NEXT"
            s.note_text = 'Promoted'
          end
          state :last do |s|
            s.description = 'Done'
            s.action_phrase = 'Fine'
          end
        end
        
        def next_state
          self.class.states[:next]
        end

        def event_status
          :new
        end
      end
    end

    it 'should have states' do
      StateBuildingExample.states.size.should == 3
    end

    it 'should order the states in created order' do
      StateBuildingExample.ordered_states[0].description.should == 'New'
      StateBuildingExample.ordered_states[1].description.should == 'Next'
      StateBuildingExample.ordered_states[2].description.should == 'Done'
    end

    it 'should return renderable transitions for any state' do
      StateBuildingExample.ordered_states[0].renderable_transitions.size.should == 1
      StateBuildingExample.ordered_states[1].renderable_transitions.size.should == 1
      StateBuildingExample.ordered_states[2].renderable_transitions.size.should == 0
    end

    it 'should not share state w/ other classes' do
      StateBuildingExample.states.should_not == RoutingExample.states 
    end

    it 'should provide access to state keys' do
      keys = StateBuildingExample.get_state_keys
      keys.include?(:new).should be_true
      keys.include?(:next).should be_true
      keys.include?(:last).should be_true
    end

    it 'should provide a list of action phrases' do
      phrases = StateBuildingExample.action_phrases_for(*StateBuildingExample.get_state_keys)
      phrases.size.should == 2
      array = phrases.collect {|p| p.phrase}
      array.include?('Moving on').should be_true
      array.include?('Fine').should be_true
    end

    it 'should have access to the states from instance methods' do
      StateBuildingExample.new.next_state.should_not be_nil
    end

    it 'should mixin an instance method' do
      StateBuildingExample.new.current_state.description.should == 'New'
    end
  end

end
