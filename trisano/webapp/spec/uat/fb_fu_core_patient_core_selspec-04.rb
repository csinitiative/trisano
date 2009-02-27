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
require File.dirname(__FILE__) + '/fb_fu_core_patient_core_base'
require 'date'
 
describe 'form builder patient-level followups for morbidity events' do
  
  #  $dont_kill_browser = true

  $fields = [{:name => 'Patient last name', :label => 'morbidity_event_active_patient__person_last_name', :entry_type => 'type', :fu_value => get_unique_name(1), :no_fu_value => get_unique_name(1)},
    {:name => 'Patient first name', :label => 'morbidity_event_active_patient__person_first_name', :entry_type => 'type',  :fu_value => get_unique_name(1), :no_fu_value => get_unique_name(1)},
#    {:name => 'Patient middle name', :label => 'morbidity_event_active_patient__person_middle_name', :entry_type => 'type',  :fu_value => get_unique_name(1), :no_fu_value => get_unique_name(1)},
#    {:name => 'Patient age', :label => 'morbidity_event_active_patient__person_approximate_age_no_birthday', :entry_type => 'type', :fu_value => '24', :no_fu_value => '44'},
#    {:name => 'Patient birth gender', :label => 'morbidity_event_active_patient__person_birth_gender_id', :entry_type => 'select', :code => 'Code: Female (gender)', :fu_value => 'Female', :no_fu_value => 'Male'},
#    {:name => 'Patient ethnicity', :label => 'morbidity_event_active_patient__person_ethnicity_id', :entry_type => 'select', :code => 'Code: Hispanic or Latino (ethnicity)', :fu_value => 'Hispanic or Latino', :no_fu_value => 'Not Hispanic or Latino'},
#    {:name => 'Patient primary language', :label => 'morbidity_event_active_patient__person_primary_language_id', :entry_type => 'select', :code => 'Code: English (language)', :fu_value => 'English', :no_fu_value => 'Japanese'}
  ]                                                  
  
  it_should_behave_like "form builder patient-level core field followups for morbidity events"
  
end
