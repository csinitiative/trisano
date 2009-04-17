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
require File.dirname(__FILE__) + '/fb_fu_core_risk_factors_base'
require 'date'
 
describe 'form builder core risk factor followups for morbidity events' do
  
  #$dont_kill_browser = true

  $fields = [
    {:name => 'Healthcare worker', :label => 'morbidity_event_interested_party_attributes_risk_factor_attributes_healthcare_worker_id', :entry_type => 'select', :code => 'Code: No (yesno)',  :fu_value => 'No', :no_fu_value => 'Unknown'},
    {:name => 'Group living', :label => 'morbidity_event_interested_party_attributes_risk_factor_attributes_group_living_id', :entry_type => 'select', :code => 'Code: Unknown (yesno)', :fu_value => 'Unknown', :no_fu_value => 'Yes'}
  ]                                                  
  
it_should_behave_like "form builder core fields risk factor followups for morbidity events"

end
