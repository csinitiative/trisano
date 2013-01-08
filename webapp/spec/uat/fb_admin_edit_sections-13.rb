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

require File.dirname(__FILE__) << '/spec_helper'

#  $dont_kill_browser = true

describe 'Form Builder Admin Edit Section Functionality' do
  
  before(:all) do
    @form_name = get_unique_name(2) << " se-uat"
    @cmr_last_name = get_unique_name(2) << " se-uat"
    @section_name = get_unique_name(2)  << " section se-uat"
    @question_text = get_unique_name(2)  << " question se-uat"
    @edited_section_name = get_unique_name(2)  << " edited se-uat"
  end
  
  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
    @section_name = nil
    @question_text = nil
    @edited_section_name = nil
  end
  
  it 'should create a form with sections' do
    create_new_form_and_go_to_builder(@browser, @form_name, "Hepatitis C, acute", "All Jurisdictions").should be_true
    add_section_to_view(@browser, "Default View", {:section_name => @section_name})
    add_question_to_section(@browser, @section_name, {:question_text => @question_text, :data_type => "Single line text", :short_name => get_random_word})
    edit_section(@browser, @section_name, @edited_section_name)
    
    publish_form(@browser).should be_true
  end
  
  it 'should show edited sections on a new cmr' do  
    create_basic_investigatable_cmr(@browser, @cmr_last_name, "Hepatitis C, acute", "Bear River Health Department")
    edit_cmr(@browser)
    @browser.is_text_present(@section_name).should be_false
    @browser.get_html_source.include?(@edited_section_name).should be_true
  end

end
