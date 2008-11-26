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

$dont_kill_browser = true

describe 'Pulling forms into an event' do
  
  before(:all) do
    @morb_anthrax_1 = get_unique_name(3) + "_pull"
    @morb_anthrax_2 = get_unique_name(3) + "_pull"
    @morb_malaria_1 = get_unique_name(3) + "_pull"
  end

  it 'should create a morbidity anthrax form' do
    create_new_form_and_go_to_builder(@browser, @morb_anthrax_1, "Anthrax", "All Jurisdictions")
    add_question_to_view(@browser, "Default View", {:question_text => "Morb Anthrax 1 Question 1", :data_type => "Single line text"})
    publish_form(@browser).should be_true
  end

  it 'should create another morbidity anthrax form' do
    create_new_form_and_go_to_builder(@browser, @morb_anthrax_2, "Anthrax", "All Jurisdictions")
    add_question_to_view(@browser, "Default View", {:question_text => "Morb Anthrax 2 Question 1", :data_type => "Single line text"})
    publish_form(@browser).should be_true
  end

  it 'should create a morbidity malaria form' do
    create_new_form_and_go_to_builder(@browser, @morb_malaria_1, "Malaria", "All Jurisdictions")
    add_question_to_view(@browser, "Default View", {:question_text => "Morb Malaria 1 Question 1", :data_type => "Single line text"})
    publish_form(@browser).should be_true
  end

# Debt: Dest contacts and places too
=begin
  it 'should create a contact anthrax form' do
    create_new_form_and_go_to_builder(@browser, "Contact Anthrax 1", "Anthrax", "All Jurisdictions", "Contact event")
    add_question_to_view(@browser, "Default View", {:question_text => "Contact Anthrax 1 Question 1", :data_type => "Single line text"})
    publish_form(@browser).should be_true
  end

  it 'should create a contact malaria form' do
    create_new_form_and_go_to_builder(@browser, "Contact Malaria 1", "Malaria", "All Jurisdictions", "Contact event")
    add_question_to_view(@browser, "Default View", {:question_text => "Contact Malaria 1 Question 1", :data_type => "Single line text"})
    publish_form(@browser).should be_true
  end

  it 'should create a contact anthrax form' do
    create_new_form_and_go_to_builder(@browser, "Place Anthrax 1", "Anthrax", "All Jurisdictions", "Place event")
    add_question_to_view(@browser, "Default View", {:question_text => "Place Anthrax 1 Question 1", :data_type => "Single line text"})
    publish_form(@browser).should be_true
  end

  it 'should create a contact malaria form' do
    create_new_form_and_go_to_builder(@browser, "Place Malaria 1", "Malaria", "All Jurisdictions", "Place event")
    add_question_to_view(@browser, "Default View", {:question_text => "Place Malaria 1 Question 1", :data_type => "Single line text"})
    publish_form(@browser).should be_true
  end

=end

  it "should create a CMR with no disease" do
    create_simplest_cmr(@browser, get_unique_name(1))
  end

  it "should validate that event_forms shows no existing forms" do
    click_core_tab(@browser, "Investigation")
    @browser.click("link=Add forms to this event")
    @browser.wait_for_page_to_load($load_time)
    @browser.is_element_present("//div[@id='forms_in_use']//tr[2]").should_not be_true
  end

  it "should validate that event_forms showsthree potential forms" do
    @browser.is_element_present("//div[@id='forms_available']//*[contains(text(), @morb_anthrax_1)]").should be_true
    @browser.is_element_present("//div[@id='forms_available']//*[contains(text(), @morb_anthrax_2)]").should be_true
    @browser.is_element_present("//div[@id='forms_available']//*[contains(text(), @morb_malaria_1)]").should be_true
  end

  it "should add a form to event" do
    @browser.click "forms_to_add[]"
    @browser.click "commit"
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present("The list of forms in use was successfully updated.").should be_true
    @browser.is_element_present("//div[@id='forms_in_use']//tr[2]").should be_true
  end

  # Create CMR with Anthrax
  # Validare 2 forms plus 1 available
  # Add form validate
  #
  # Create CMR with Anthrax, contact, and place
  # Edit contact
  # validate 1 + 1
  # add form and validate
  #
  # Edit place
  # Validate 1 + 1
  # add form and validate
end
