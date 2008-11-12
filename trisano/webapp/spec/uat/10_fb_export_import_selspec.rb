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

# $dont_kill_browser = true

describe 'Form Builder Admin Standard Follow-Up Functionality' do
  
  before(:all) do
    @form_name = get_unique_name(2)
    @section_name = get_unique_name(2) << " fb-ex-uat"
    @section_question_text = get_unique_name(2) << " fb-ex-uat"
    @tab_name = get_unique_name(2) << " fb-ex-uat"
    @tab_question_text = get_unique_name(2) << " fb-ex-uat"
    
  end
  
  after(:all) do
    @form_name = nil
    @section_name = nil
    @section_question_text = nil
    @tab_name = nil
    @tab_question_text = nil
  end
  
  it 'should export and import forms' do
    create_new_form_and_go_to_builder(@browser, @form_name, "African Tick Bite Fever", "All Jurisdictions")
    
    add_section_to_view(@browser, "Default View", {:section_name => @section_name})
    add_question_to_section(@browser, @section_name, {:question_text => @section_question_text, :data_type => "Single line text"})
    
    add_view(@browser, @tab_name)
    add_question_to_view(@browser, @tab_name, {:question_text => @tab_question_text, :data_type => "Single line text"})

    click_nav_forms(@browser)

    # The rest relies on browser profile changes that we need to get dialed in. Works if you uncomment and
    # also use the alternate @browser initialization in spec_helper.
    #
#    click_form_export(@browser, @form_name).should be_true
#    sleep 2
#    File.exist?("#{$trisano_download_file_url}#{@form_name.downcase.sub(" ", "_")}.zip").should be_true
#
#    @browser.type("form_import", "#{$trisano_download_file_url}#{@form_name.downcase.sub(" ", "_")}.zip")
#    @browser.click("//input[@value='Upload']")
#    @browser.wait_for_page_to_load($load_time)
#    @browser.click "link=Form Builder"
#    @browser.wait_for_page_to_load($load_time)
#
#    @browser.is_text_present(@form_name).should be_true
#    @browser.is_text_present(@section_name).should be_true
#    @browser.is_text_present(@section_question_text).should be_true
#    @browser.is_text_present(@tab_name).should be_true
#    @browser.is_text_present(@tab_question_text).should be_true
    
  end
    
end
