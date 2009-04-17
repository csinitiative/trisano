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

  $fields = [
    {:name => 'Patient middle name', :label => "//div[@id='demographic_tab']//div[@id='person_form']//input[contains(@id, '_middle_name')]", :entry_type => 'type',  :fu_value => get_unique_name(1), :no_fu_value => get_unique_name(1)},
    {:name => 'Patient age', :label => "//div[@id='demographic_tab']//div[@id='person_form']//input[contains(@id, '_approximate_age_no_birthday')]", :entry_type => 'type', :fu_value => '24', :no_fu_value => '44'}
  ]                                                  
  
  it_should_behave_like "form builder patient-level core field followups for morbidity events"
  
end
