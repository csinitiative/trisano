# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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
 
describe 'form builder invalid core field configs' do
  
  #  $dont_kill_browser = true
  
  before(:all) do
    @form_name = get_unique_name(2) + " ifu-uat"
  end
  
  after(:all) do
    @form_name = nil
  end
    
  it 'should create a form for a morbidity event' do
    create_new_form_and_go_to_builder(@browser, @form_name, "Malaria", "Davis County Health Department").should be_true
  end
  
  it 'should add a core field config' do
    add_core_field_config(@browser, "Patient birth gender")
    @browser.is_text_present("Core field configuration is invalid").should be_false
  end
 
  it 'should change the form to a contact form.' do
    @browser.click("link=Edit")
    @browser.wait_for_page_to_load($load_time)
    edit_form_and_go_to_builder(@browser,:event_type => "Contact Event").should be_true
  end
  
  it 'should mark existing core field as invalid' do
    @browser.is_text_present("Core field configuration is invalid").should be_true
  end
  
end