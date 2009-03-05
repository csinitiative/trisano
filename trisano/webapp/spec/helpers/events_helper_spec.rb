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
require RAILS_ROOT + '/app/helpers/application_helper'

describe EventsHelper do

  include ApplicationHelper

  describe "the state_controls method" do

    describe "when the event state is 'asssigned to LHD'" do
      before(:each) do
        mock_user
        mock_event
        @event_1.stub!(:event_status).and_return("ASGD-LHD")
        @jurisdiction = mock_model(Place)
        @jurisdiction.stub!(:entity_id).and_return(1)
        User.stub!(:current_user).and_return(@user)
      end

      describe "and the user is allowed to accept an event" do
        before(:each) do
          @user.stub!(:is_entitled_to_in?).and_return(true)
        end
       
        it "should return a properly constructed form that posts to the morbidity event's controller's state action" do
          pending "There are serious difficulties testing Haml helpers in RSpec.  Pending till figured out."
          form = state_controls(@event_1, @jurisdiction)
          # form test here
          # radio button test here
        end
          
      end

      describe "when the user is not allowed to accept an event" do
      end
    end
   
    # Repeat the above pattern as new state transitions are implemented
  end

  describe "original patient controls" do

    it 'should display the patient name and disease for the parent event' do
      @event = mock_event
      @encounter_event = mock_model(EncounterEvent)
      @encounter_event.stub!(:parent_event).and_return(@event)
      helper.original_patient_controls(@encounter_event).include?("Groucho Marx").should be_true
      helper.original_patient_controls(@encounter_event).include?("Bubonic,Plague").should be_true
    end
   
  end
  
end
