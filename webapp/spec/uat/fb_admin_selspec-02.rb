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

describe 'Form Builder Admin' do

  before(:all) do
    @form_name = get_unique_name(4) + " fb uat"

    @question_to_add_to_library_text = "Was this added to the library " + get_unique_name(4) + " fb uat"
    @question_to_delete_text = "Describe the tick " + get_unique_name(4) + " fb uat"
    @question_to_edit_text = "Can you describe the tick " + get_unique_name(4) + " fb uat"
    @question_to_edit_modified_text = "Can you describe the tick edited " + get_unique_name(4) + " fb uat"
    @question_to_inactivate_text = "Did you see the tick that got you " + get_unique_name(4) + " fb uat"

    @user_defined_tab_text = "User-defined tab " + get_unique_name(3) + " fb uat"
    @user_defined_tab_section_text = "User-defined tab section " + get_unique_name(3) + " fb uat"
    @user_defined_tab_question_text = "User-defined tab questoin " + get_unique_name(3) + " fb uat"

    @cmr_last_name = get_unique_name(1) + " fb uat"
  end

  after(:all) do
    @form_name = nil
    @question_to_delete_text = nil
    @question_to_edit_text = nil
    @question_to_edit_modified_text = nil
    @cmr_last_name = nil
  end

  it 'should create a new form and allow navigation to builder' do
    create_new_form_and_go_to_builder(@browser, @form_name, "African Tick Bite Fever", "All Jurisdictions")
  end

  # Debt: The remaining examples had to be combined into one in order to have access
  # to saved IDs across what used to be separate examples.
  # The methods provide some segmentation of all of the activities of the large example.
  it 'should do all this stuff...' do

    to_and_from_library_new_group
    to_and_from_library_no_group
    add_a_section
    add_questions
    reorder_elements
    add_value_sets
    edit_value_sets
    add_and_populate_tab
    publish_form(@browser).should be_true
    @browser.is_text_present("Form was successfully published").should be_true
    validate_investigator_rendering
    navigate_to_form_edit
    delete_edit_and_inactivate_questions
    publish_form(@browser).should be_true
    @browser.is_text_present("Form was successfully published").should be_true

  end
end

def add_a_section
  @browser.click "link=Add section to tab"
  wait_for_element_present("new-section-form")
  @browser.type "section_element_name", "Section 1"
  @browser.click "//input[contains(@id, 'create_section_submit')]"
  wait_for_element_not_present("new-section-form")
  @browser.is_text_present("Section 1").should be_true

  @reorderable_section_id = "section_#{@browser.get_value("id=modified-element")}_children"
end

def add_questions
  add_question_to_section(@browser, "Section 1", {:question_text => "Did you go into the tall grass?", :data_type => "Drop-down select list", :short_name => get_random_word})
  @browser.is_text_present("Did you go into the tall grass?").should be_true

  add_question_to_section(@browser, "Section 1", {:question_text => @question_to_inactivate_text, :data_type => "Drop-down select list", :short_name => get_random_word})
  @browser.is_text_present(@question_to_inactivate_text).should be_true

  @question_to_inactivate_id = @browser.get_value("id=modified-element")

  add_question_to_section(@browser, "Section 1", {:question_text => @question_to_delete_text, :data_type => "Multi-line text", :short_name => get_random_word})
  @browser.is_text_present(@question_to_delete_text).should be_true

  @question_to_delete_id = @browser.get_value("id=modified-element")

  add_question_to_section(@browser, "Section 1", {:question_text => @question_to_edit_text, :data_type => "Drop-down select list", :short_name => get_random_word})
  @browser.is_text_present(@question_to_edit_text).should be_true

  @question_to_edit_id = @browser.get_value("id=modified-element")
end

def add_value_sets
  add_value_set_to_question(@browser,
    "Did you go into the tall grass?",
    "Yes/No/Maybe",
    [{ :name => "Yes" }, { :name => "No" }, { :name => "Maybe" }]
  ).should be_true

  add_value_set_to_question(@browser,
    @question_to_inactivate_text,
    "Yes/No",
    [{ :name => "Yes" }, { :name => "No" }]
  ).should be_true

  add_value_set_to_question(@browser,
    @question_to_edit_text,
    "Yes/No",
    [{ :name => "Yes" }, { :name => "No" }]
  ).should be_true
end

def reorder_elements
  @browser.get_eval("nodes = window.document.getElementById(\"#{@reorderable_section_id}\").getElementsByTagName('li'); firstItem =nodes[0].id.toString().substring(9); secondItem =nodes[1].id.toString().substring(9); firstItem > secondItem").should == "false"
  @browser.dragdrop "//ul[@id='#{@reorderable_section_id}']/li[2]", "0,-40"
  @browser.wait_for_ajax
  @browser.get_eval("nodes = window.document.getElementById(\"#{@reorderable_section_id}\").getElementsByTagName('li'); firstItem =nodes[0].id.toString().substring(9); secondItem =nodes[1].id.toString().substring(9); firstItem > secondItem").should == "true"
end

def edit_value_sets
  @browser.click "link=Edit value set"
  wait_for_element_present("edit-value-set-form")
  @browser.is_element_present("edit-value-set-form").should be_true
  @browser.type "value_set_element_name", "Edited value set"
  @browser.click "//input[contains(@id, 'edit_value_set_submit')]"
  wait_for_element_not_present("edit-value-set-form")

  @browser.click "link=Inactivate"
  sleep(2)
  @browser.is_text_present("Edited value set").should be_true
  @browser.is_text_present("Inactive").should be_true
end

def add_and_populate_tab

  @browser.click("add-tab")
  wait_for_element_present("new-view-form")
  @browser.type "view_element_name", @user_defined_tab_text
  @browser.click "//input[contains(@id, 'create_view_submit')]"
  wait_for_element_not_present("new-view-form")

  @tab_element_id = @browser.get_value("id=modified-element")

  @browser.click "id=add-section-#{@tab_element_id}"
  wait_for_element_present("new-section-form")
  @browser.type "section_element_name", @user_defined_tab_section_text
  @browser.click "//input[contains(@id, 'create_section_submit')]"
  wait_for_element_not_present("new-section-form")
  @browser.is_text_present(@user_defined_tab_text).should be_true

  @tab_section_element_id = @browser.get_value("id=modified-element")

  add_question_to_section(@browser, @user_defined_tab_section_text, {:question_text => @user_defined_tab_question_text, :data_type => "Single line text", :short_name => get_random_word})
  @browser.is_text_present(@user_defined_tab_question_text).should be_true
end

def to_and_from_library_no_group

  # Debt: This could be refactored to use the #add_question_to_library helper method
  @browser.click "link=Copy to library"
  wait_for_element_present("new-group-form")
  @browser.click "link=No Group"
  sleep(2)
  # Commenting out until UI settles down on library -- library functionality is checked in other tests
  # num_times_text_appears(@browser, @question_to_add_to_library_text).should == 2
  @browser.click "link=Close"

  @browser.click "link=Add question to tab"
  wait_for_element_present("new-question-form")

  @browser.click("link=Show all groups")
  # Debt: If this UI sticks, add something to key off of instead of using this sleep
  sleep(2)

  @browser.click "link=#{@question_to_add_to_library_text}"
  sleep(2)
  # Commenting out until UI settles down on library -- library functionality is checked in other tests
  # num_times_text_appears(@browser, @question_to_add_to_library_text).should == 2 #library closed or would be 3
end

def to_and_from_library_new_group

  # Debt: This could be refactored to use the #add_question_to_library helper method
  add_question_to_view(@browser, "Default View", {:question_text => @question_to_add_to_library_text, :data_type => "Single line text", :short_name => get_random_word})
  num_times_text_appears(@browser, @question_to_add_to_library_text).should == 1
  group_name = get_unique_name(3)
  @browser.click "link=Copy to library"
  wait_for_element_present("new-group-form")
  @browser.type "group_element_name", group_name
  @browser.click "group_element_submit"
  sleep(2)
  @browser.click "link=Add element to: #{group_name}"
  sleep(2)
  # Commenting out until UI settles down on library -- library functionality is checked in other tests
  # num_times_text_appears(@browser, @question_to_add_to_library_text).should == 3
  @browser.click "link=Close"
end

def validate_investigator_rendering
  create_basic_investigatable_cmr(@browser, @cmr_last_name, "African Tick Bite Fever", "Bear River Health Department")
  edit_cmr(@browser)
  html_source = @browser.get_html_source
  html_source.include?(@question_to_delete_text).should be_true
  html_source.include?(@question_to_edit_text).should be_true
  html_source.include?(@question_to_inactivate_text).should be_true
  html_source.include?(@question_to_edit_modified_text).should be_false
  html_source.include?(@user_defined_tab_text).should be_true
  html_source.include?(@user_defined_tab_section_text).should be_true
  html_source.include?(@user_defined_tab_question_text).should be_true
end

def navigate_to_form_edit
  click_nav_forms(@browser)
  click_build_form(@browser, @form_name)
end

def delete_edit_and_inactivate_questions
  delete_question(@browser, @question_to_delete_text)
  sleep(1)
  @browser.click "id=edit-question-#{@question_to_edit_id}"
  wait_for_element_present("edit-question-form")
  @browser.type "question_element_question_attributes_question_text", @question_to_edit_modified_text
  @browser.click "//input[contains(@id, 'edit_question_submit')]"
  wait_for_element_not_present("edit-question-form")
  @browser.is_text_present(@question_to_edit_text).should be_false
  @browser.is_text_present(@question_to_edit_modified_text).should be_true

  @browser.click "id=edit-question-#{@question_to_inactivate_id}"
  wait_for_element_present("edit-question-form")
  @browser.click "question_element_is_active_false"
  @browser.click "//input[contains(@id, 'edit_question_submit')]"
  wait_for_element_not_present("edit-question-form")
end
