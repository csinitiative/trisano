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

#$dont_kill_browser = true

describe 'Pulling forms into an event' do
  
  before(:all) do
    @morb_anthrax_1 = get_unique_name(3) + "_pull"
    @morb_anthrax_2 = get_unique_name(3) + "_pull"
    @morb_malaria_1 = get_unique_name(3) + "_pull"
  end

  it 'should create a morbidity anthrax form' do
    create_new_form_and_go_to_builder(@browser, @morb_anthrax_1, "Anthrax", "All Jurisdictions")
    add_question_to_view(@browser, "Default View", {:question_text => "Morb Anthrax 1 Question 1", :data_type => "Single line text", :short_name => "1"})
    publish_form(@browser).should be_true
  end

  it 'should create another morbidity anthrax form' do
    create_new_form_and_go_to_builder(@browser, @morb_anthrax_2, "Anthrax", "All Jurisdictions")
    add_question_to_view(@browser, "Default View", {:question_text => "Morb Anthrax 2 Question 1", :data_type => "Single line text", :short_name => "2"})
    publish_form(@browser).should be_true
  end

  it 'should create a morbidity malaria form' do
    create_new_form_and_go_to_builder(@browser, @morb_malaria_1, "Malaria", "All Jurisdictions")
    add_question_to_view(@browser, "Default View", {:question_text => "Morb Malaria 1 Question 1", :data_type => "Single line text", :short_name => "3"})
    publish_form(@browser).should be_true
  end

  it "should create a CMR with no disease" do
    create_simplest_cmr(@browser, get_unique_name(1))
  end

  it "should validate that event_forms shows no existing forms" do
    click_core_tab(@browser, "Investigation")
    @browser.click("link=Add/Remove forms for this event")
    @browser.wait_for_page_to_load($load_time)
    @browser.is_element_present("//div[@id='forms_in_use']//tr[2]").should_not be_true
  end

  it "should validate that event_forms shows three potential forms" do
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

end
