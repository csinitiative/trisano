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

describe '/contact_events/edit.html.erb' do

  before(:each) do
    @user = mock_user
    User.stub!(:current_user).and_return(@user)

    @update_event = mock('update_event')
    @entitlements = mock('entitlements')
    @entitlements.stub!(:for_jurisdiction).and_return([])
    @update_event.stub!(:entitlements).and_return(@entitlements)
    Privilege.stub!(:update_event).and_return(@update_event)

    @patient_entity = mock('patient entity')
    @patient_entity.stub!(:person).and_return(Person.new(:last_name => 'Biel'))
    @patient_entity.stub!(:address).and_return(nil)
    @patient_entity.stub!(:race_ids).and_return([])
    @patient_entity.stub!(:address_entities_locations).and_return([])
    @patient_entity.stub!(:telephone_entities_locations).and_return([])    

    @active_patient = mock('active patient participation')
    @active_patient.stub!(:primary_entity).and_return(@patient_entity)
    @active_patient.stub!(:participations_risk_factor).and_return(nil)
    @active_patient.stub!(:participations_contact).and_return(nil)
    @active_patient.stub!(:participations_treatments).and_return([])    

    @jurisdiction_place = mock('jurisdiction place')
    @jurisdiction_place.stub!(:short_name).and_return("Bill's")
    @jurisdiction_place.stub!(:entity_id).and_return(1)

    @jurisdiction_place_entity = mock('jurisdiction place entity')
    @jurisdiction_place_entity.stub!(:place).and_return(@jurisdiction_place)

    @active_jurisdiction = mock('jurisdiction participation')
    @active_jurisdiction.stub!(:secondary_entity).and_return(@jurisdiction_place_entity)

    @parent_event = MorbidityEvent.new
    @parent_event.stub!(:active_patient).and_return(@active_patient)

    @event = ContactEvent.new
    @event.stub!(:parent_event).and_return(@parent_event)
    @event.stub!(:active_patient).and_return(@active_patient)
    @event.stub!(:patient).and_return(@active_patient)
    @event.stub!(:active_jurisdiction).and_return(@active_jurisdiction)

    @event.parent_guardian = 'The State'

    assigns[:event] = @event
  end

  it 'should have parent/guardian field' do
    pending "Too damn complicated for now."
    render '/contact_events/edit.html.erb'
    response.should have_tag('label', :text => 'Parent/Guardian')
    response.should have_tag('input#contact_event_parent_guardian')
  end

end
