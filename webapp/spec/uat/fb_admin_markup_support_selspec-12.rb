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

describe 'Form Builder Markup Support' do

  before(:all) do
    @form_name = get_unique_name(2) + " markup"
    @cmr_last_name = get_unique_name(1) + " markup"
    @disease = get_random_disease
    @section_name = get_unique_name(2)
    @section_help = get_unique_name(2)
    @section_instructions = get_unique_name(2)
    @question_text = get_unique_name(2)
    @help_text = get_unique_name(2)
  end

  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
    @disease = nil
    @section_name = nil
    @section_help = nil
    @section_instructions = nil
    @question_text = nil
    @help_text = nil
  end

  it 'should allow the addition of sections and questions with text containing HTML.' do
    create_new_form_and_go_to_builder(@browser, @form_name, @disease, "All Jurisdictions").should be_true

    add_section_to_view(@browser, "Default View", {
        :section_name => @section_name + "<br><b>section</b><i>name</i>",
        :description => @section_instructions + "<br><b>section</b><i>instructions</i>",
        :help_text => @section_help + "<br><b>section</b><i>help</i>"
      })

    add_question_to_section(
      @browser, @section_name,
      {
        :question_text => @question_text + "<br><b>question</b><i>text</i>",
        :data_type => "Single line text",
        :help_text => @help_text + "<br><b>help</b><i>text</i>",
        :short_name => get_random_word
      }
    )
    publish_form(@browser)
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @disease, "Bear River Health Department")
  end

  it "shouldn't display any markup other than line breaks for sections and questions in edit mode" do
    edit_cmr(@browser)
    markup_assertions(:edit)
  end

  it "shouldn't display any markup other than line breaks for sections and questions in show mode" do
    save_cmr(@browser)
    markup_assertions(:show)
  end

  it "shouldn't display any markup other than line breaks for sections and questions in print mode" do
    print_cmr(@browser)
    markup_assertions(:print)
  end
  
end

def markup_assertions(mode)
  html_source = @browser.get_html_source
  html_source.include?(@section_name + "<br><b>section</b><i>name</i>").should be_false
  html_source.include?(@section_name + "sectionname").should be_true
  html_source.include?(@section_instructions + "<br><b>section</b><i>instructions</i>").should be_false
  html_source.include?(@section_instructions + "<br>sectioninstructions").should be_true
  html_source.include?(@section_help + "<br><b>section</b><i>help</i>").should be_false unless mode == :print
  html_source.include?(@section_help + "<br>sectionhelp").should be_true unless mode == :print
  html_source.include?(@question_text + "<br><b>question</b><i>text</i>").should be_false
  html_source.include?(@question_text + "<br>questiontext").should be_true
  html_source.include?(@help_text + "<br><b>help</b><i>text</i>").should be_false unless mode == :print
  html_source.include?(@help_text + "<br>helptext").should be_true unless mode == :print
end
