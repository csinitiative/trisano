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

describe '/morbidity_events/show.html.erb' do

  before(:each) do
    @user = mock_user
    User.stub!(:current_user).and_return(@user)

    @update_event = mock('update_event')
    @entitlements = mock('entitlements')
    @entitlements.stub!(:for_jurisdiction).and_return([])
    @update_event.stub!(:entitlements).and_return(@entitlements)
    Privilege.stub!(:update_event).and_return(@update_event)
    
    @patient_entity = stub_model(PersonEntity)
    @patient_entity.stub!(:person).and_return(Person.new(:last_name => 'Biel'))
    @patient_entity.stub!(:address).and_return(nil)
    @patient_entity.stub!(:telephones).and_return([])


    @active_patient = stub_model(InterestedParty)
    @active_patient.stub!(:person_entity).and_return(@patient_entity)

    @active_patient.stub!(:participations_risk_factor).and_return(nil)
    @active_patient.stub!(:participations_treatments).and_return([])

    @jurisdiction_place = stub_model(Place)
    @jurisdiction_place.stub!(:short_name).and_return("Bill's")
    @jurisdiction_place.stub!(:entity_id).and_return(1)

    @jurisdiction_place_entity = stub_model(PlaceEntity)
    @jurisdiction_place_entity.stub!(:place).and_return(@jurisdiction_place)

    @active_jurisdiction = stub_model(Jurisdiction)
    @active_jurisdiction.stub!(:place_entity).and_return(@jurisdiction_place_entity)

    # @event = MorbidityEvent.new
    @event = stub_model(MorbidityEvent)
    @event.stub!(:interested_party).and_return(@active_patient)
    @event.stub!(:patient).and_return(@active_patient)
    @event.stub!(:jurisdiction).and_return(@active_jurisdiction)
    @event.stub!(:current_state).and_return(Event.states['NEW'])

    @event.stub!(:parent_guardian).and_return('Blurgh Non-sense splat')

    assigns[:event] = @event
  end

  it 'should show parent/guardian info' do
    pending "Too damn complicted for now"
    render '/morbidity_events/show.html.erb'
    response.should have_tag('label', :text => 'Parent/Guardian')
    response.should have_tag('span.horiz', :text => /Blurgh Non-sense splat/)
  end

end
