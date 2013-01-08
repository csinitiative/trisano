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

# $dont_kill_browser = true

describe 'Adding help text to form builder questions' do
  
  before :each do
    @form_name = get_unique_name(2)  << " s-hlp-uat"
    @section_name = get_unique_name(2)  << " s-hlp-uat"
    @question_text = get_unique_name(2)  << " s-hlp-uat"
    @instruction_text = get_unique_name(10) << " s-hlp-uat"
    @help_text = get_unique_name(10) << " s-hlp-uat"
    @cmr_last_name = get_unique_name(1)  << " s-hlp-uat"
  end

  after :each do
    @form_name = nil
    @section_name = nil
    @question_text = nil
    @help_text = nil
    @instruction_text = nil
    @cmr_last_name = nil
  end

  describe 'on sections with instructions and help text' do
    it "should create a section w/instructions and help text" do
      disease = get_random_disease
      create_new_form_and_go_to_builder(@browser, @form_name, disease, 'All Jurisdictions').should be_true
      add_section_to_view(@browser, "Default View", {:section_name => @section_name, :description => @instruction_text, :help_text => @help_text})
      add_question_to_section(@browser, @section_name, {:question_text => @question_text, :data_type => "Single line text", :short_name => get_random_word})
      publish_form(@browser).should be_true
      create_basic_investigatable_cmr(@browser, @cmr_last_name, disease, 'Summit County Public Health Department').should be_true
      edit_cmr(@browser).should be_true
      click_core_tab(@browser, 'Investigation')
      assert_tooltip_exists(@browser, @help_text).should be_true
      @browser.get_html_source.include?(@instruction_text).should be_true
      answer_investigator_question(@browser, @question_text, "Answer").should be_true
      save_cmr(@browser).should be_true
      assert_tooltip_exists(@browser, @help_text).should be_true
      @browser.get_html_source.include?(@instruction_text).should be_true
      
      print_cmr(@browser).should be_true
      @browser.get_html_source.include?(@instruction_text).should be_true
      @browser.close()
      @browser.select_window 'null'
    end
  end

end
