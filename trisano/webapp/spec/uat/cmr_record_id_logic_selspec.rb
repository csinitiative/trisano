# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

describe 'System functionality for setting the record ID of a CMR' do

  it 'should create two CMRs in a row with sequential record numbers that start with the current year' do
    @browser.open "/trisano/cmrs"
    click_nav_new_cmr(@browser).should be_true
    @browser.type('morbidity_event_active_patient__active_primary_entity__person_last_name', 'Record')
    @browser.type('morbidity_event_active_patient__active_primary_entity__person_first_name', 'Number')
    save_cmr(@browser).should be_true
    recNum = get_record_number(@browser)
    click_nav_new_cmr(@browser).should be_true
    @browser.type('morbidity_event_active_patient__active_primary_entity__person_last_name', 'Next')
    @browser.type('morbidity_event_active_patient__active_primary_entity__person_first_name', 'Record')
    save_cmr(@browser).should be_true
    click_core_tab(@browser, "Clinical")
    nextRecNum = get_record_number(@browser)
    ((nextRecNum.to_i - recNum.to_i)==1).should be_true
    (recNum[0,4]==Time.now.year.to_s).should be_true
    (nextRecNum[0,4]==Time.now.year.to_s).should be_true
  end
end
