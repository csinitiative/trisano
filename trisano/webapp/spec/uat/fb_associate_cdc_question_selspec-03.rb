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

require File.dirname(__FILE__) << '/spec_helper'

# $dont_kill_browser = true

describe 'Form Builder CDC mapping functionality' do
  
  before(:all) do
    @form_name = get_unique_name(2) << " cdcq-uat"
    @question_text = get_unique_name(2)  << " cdcq-uat"
  end
  
  after(:all) do
    @form_name = nil
    @question_text = nil
  end
  
  it 'should handle CDC question mapping' do
    create_new_form_and_go_to_builder(@browser, @form_name, "Hepatitis A, acute", "All Jurisdictions")
    add_question_to_view(@browser, "Default View", {:question_text => @question_text, :export_column_id => "Where"}).should be_true
    @browser.is_text_present("Radio button, CDC value")
  end
  
  it 'should build a value set when applicable' do
    # Check a sampling of the values
    @browser.is_text_present("Africa")
    @browser.is_text_present("Carribean")
    @browser.is_text_present("Middle East")
  end
  
  it 'should create a date type when applicable' do
    add_question_to_view(@browser, "Default View", {:question_text => @question_text, :export_column_id => "Date Dx"}).should be_true
    @browser.is_text_present("Date, CDC value")
  end
  
  it 'should create a string type when applicable' do
    add_question_to_view(@browser, "Default View", {:question_text => @question_text, :export_column_id => "Vaccine Year"}).should be_true
    @browser.is_text_present("Single line text, CDC value")
  end

end
