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
require File.dirname(__FILE__) + '/fb_fu_core_patient_address_base'
require 'date'
 
describe 'form builder patient-level address core followups for morbidity events' do
  
  #  $dont_kill_browser = true

  $fields = [
    {:name => 'Patient state', :label => "//div[@id='demographic_tab']//div[@id='person_form']//select[contains(@id, '_state_id')]", :entry_type => 'select', :code => 'Code: Utah (state)', :fu_value => 'Utah', :no_fu_value => 'Texas'},
    {:name => 'Patient county', :label => "//div[@id='demographic_tab']//div[@id='person_form']//select[contains(@id, '_county_id')]", :entry_type => 'select', :code => 'Code: Utah (county)', :fu_value => 'Utah', :no_fu_value => 'Davis'}
  ]
  
  it_should_behave_like "form builder patient-level address core field followups for morbidity events"

end
