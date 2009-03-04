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

require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/fb_fu_contact_patient_address_base'
require 'date'
 
describe 'form builder patient-level address follow-ups for contact events' do

#  $dont_kill_browser = true

  $fields = [{:name => 'Contact street number', :label => 'contact_event_interested_party_attributes_person_entity_attributes_address_attributes_street_number', :entry_type => 'type', :fu_value => '444', :no_fu_value => '222'},
    {:name => 'Contact street name', :label => 'contact_event_interested_party_attributes_person_entity_attributes_address_attributes_street_name', :entry_type => 'type', :fu_value => 'Chaff Drive', :no_fu_value => 'Chart Drive'},
    {:name => 'Contact unit number', :label => 'contact_event_interested_party_attributes_person_entity_attributes_address_attributes_unit_number', :entry_type => 'type', :fu_value => '444', :no_fu_value => '222'}
  ]

  it_should_behave_like "form builder patient-level address follow-ups for fields on contact events"
end
