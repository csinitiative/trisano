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

describe 'Form Builder Admin Delete Element Functionality' do

  before(:all) do
    @form_name = get_unique_name(2) + " d-uat"
    @cmr_last_name = get_unique_name(1) + " d-uat"
    @tab_name = get_unique_name(2)  + " tab d-uat"
    @section_name = get_unique_name(2)  + " section d-uat"
    @question_text = get_unique_name(2)  + " question d-uat"
    @value_set_question_text = get_unique_name(2)  + " question d-uat"
    @value_set_name = get_unique_name(2)  + " vs d-uat"
    @value_set_value_one = get_unique_name(2)  + " vsv d-uat"
    @value_set_value_two = get_unique_name(2)  + " vsv d-uat"
    @value_set_value_three = get_unique_name(2)  + " vsv d-uat"
    @patient_last_name_before_question_text = get_unique_name(2)  + " cfb d-uat"
    @patient_last_name_after_question_text = get_unique_name(2) + " cfa d-uat"
    @patient_disease = get_random_disease
  end

  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
    @tab_name = nil
    @section_name = nil
    @question_text = nil
    @value_set_question_text = nil
    @value_set_name = nil
    @value_set_value_one = nil
    @value_set_value_two = nil
    @value_set_value_three = nil
    @patient_last_name_before_question_text = nil
    @patient_last_name_after_question_text = nil
  end

  it 'should create a form' do
    create_new_form_and_go_to_builder(@browser, @form_name, @patient_disease, "All Jurisdictions")
    add_view(@browser, @tab_name)
    add_section_to_view(@browser, "Default View", {:section_name => @section_name})
    add_question_to_view(@browser, "Default View", {:question_text => @question_text, :data_type => "Single line text", :short_name => get_random_word})
    add_question_to_view(@browser, "Default View", {:question_text => @value_set_question_text, :data_type => "Drop-down select list", :short_name => get_random_word})
    add_value_set_to_question(@browser,
      @value_set_question_text,
      @value_set_name,
      [{ :name => @value_set_value_one }, { :name => @value_set_value_two }, { :name => @value_set_value_three }]
    ).should be_true
    add_core_field_config(@browser, "Patient last name")
    add_question_to_before_core_field_config(@browser, "Patient last name", {:question_text =>@patient_last_name_before_question_text, :data_type => "Single line text", :short_name => get_random_word}).should be_true
    add_question_to_after_core_field_config(@browser, "Patient last name", {:question_text =>@patient_last_name_after_question_text, :data_type => "Single line text", :short_name => get_random_word}).should be_true

    publish_form(@browser).should be_true
  end

  it 'should create an investigatable cmr and answer form questions' do
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @patient_disease, "Bear River Health Department").should be_true
    edit_cmr(@browser).should be_true

    html_source = @browser.get_html_source
    html_source.include?(@tab_name).should be_true
    html_source.include?(@section_name).should be_true
    html_source.include?(@question_text).should be_true
    html_source.include?(@value_set_value_one).should be_true
    html_source.include?(@value_set_value_two).should be_true
    html_source.include?(@patient_last_name_before_question_text).should be_true
    html_source.include?(@patient_last_name_after_question_text).should be_true
  end

  it 'should delete questions, tabs, sections, value sets and core fields' do
    click_nav_forms(@browser)
    click_build_form(@browser, @form_name)

    delete_view(@browser, @tab_name).should be_true
    delete_section(@browser, @section_name).should be_true
    delete_question(@browser, @question_text).should be_true
    delete_value_set(@browser, @value_set_name).should be_true
    delete_core_field_config(@browser, "Patient last name").should be_true

    publish_form(@browser)
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @patient_disease, "Bear River Health Department").should be_true
    edit_cmr(@browser).should be_true
  end

  it 'should not find info related to delete questions' do
    html_source = @browser.get_html_source
    html_source.include?(@tab_name).should be_false
    html_source.include?(@section_name).should be_false
    html_source.include?(@question_text).should be_false
    html_source.include?(@value_set_value_one).should be_false
    html_source.include?(@value_set_value_two).should be_false
    html_source.include?(@patient_last_name_before_question_text).should be_false
    html_source.include?(@patient_last_name_after_question_text).should be_false
  end

end
