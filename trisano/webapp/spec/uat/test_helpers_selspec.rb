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

require 'active_support'

require File.dirname(__FILE__) + '/spec_helper'

describe 'Trisano helper methods' do
  
  #  $dont_kill_browser = true
  
  before(:all) do
    @last_name = get_unique_name(1)
    @browser.open "/trisano/cmrs"
  end

  it 'should save a CMR with basic info' do
    @disease = get_random_disease
    @jurisdiction = get_random_jurisdiction
    create_basic_investigatable_cmr(@browser, @last_name, @disease, @jurisdiction).should be_true
  end
  
  it 'should add a lab result' do
    #    edit_cmr(@browser).should be_true
    #    add_lab_result(@browser, {:lab_name => "Joe's Crab Shack", :lab_result_text => "Bad news dood"}).should be_true
    #    save_cmr(@browser).should be_true
  end
  
  it 'should save the treatment info' do
    edit_cmr(@browser).should be_true
    add_treatment(@browser, {:treatment_given => 'label=Yes', :treatment => 'Leaches'}, 1)
    save_cmr(@browser).should be_true
  end
  
  it 'should save the reporting info' do
  end

  it 'should save administrative info' do
  end
  
  it 'should still have all the data present' do
  end
  it 'should only return diseases that are valid' do
    click_nav_new_cmr(@browser)
    click_core_tab(@browser, CLINICAL)
    (0..132).each do |x|
      @disease = get_random_disease(x)
      @browser.select("morbidity_event_disease_disease_id", @disease)
      @browser.is_text_present(@disease).should be_true
    end
  end

  it 'should only return jurisdictions that are valid' do
    click_core_tab(@browser, ADMIN)
    (0..14).each do |x|
      @juris = get_random_jurisdiction(x)
      @browser.select("morbidity_event_active_jurisdiction_secondary_entity_id", @juris)
      @browser.is_text_present(@juris).should be_true
    end
  end
end
