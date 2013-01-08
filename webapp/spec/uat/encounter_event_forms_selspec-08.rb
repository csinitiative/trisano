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

describe 'Encounter event forms' do

 # $dont_kill_browser = true

  before(:all) do
    @form_name = get_unique_name(4) + " en-f uat"
    @second_form_name = get_unique_name(4) + " en-f uat"
    @disease = get_random_disease
    @question_text = get_unique_name(4) + " en-f uat"
    @question_answer = get_unique_name(4) + " en-f uat"
    @second_question_text = get_unique_name(4) + " en-f uat"
    @cmr_last_name = get_random_word << " en-f-uat"
    @date = "March 10, 2009"
    @description = get_unique_name(3) << " en-f-uat"
  end

  after(:all) do
    @form_name = nil
    @second_form_name = nil
    @disease = nil
    @question_text = nil
    @question_answer = nil
    @second_question_text = nil
    @cmr_last_name = nil
    @date = nil
    @description = nil
  end

  it "should create a basic form for encounter events" do
    @browser.open "/trisano"
    create_new_form_and_go_to_builder(@browser, @form_name, @disease, "All Jurisdictions", "Encounter Event")
    add_question_to_view(@browser, "Default View", {
        :question_text => @question_text,
        :data_type => 'Single line text',
        :short_name => get_random_word
      })
    publish_form(@browser)
  end

  it 'should create a basic investigatable CMR' do
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @disease).should be_true
  end

  it 'should add an encounter' do
    edit_cmr(@browser)
    @browser.type('css=input[id$=participations_encounter_attributes_encounter_date]', @date)
    @browser.type('css=textarea[id$=participations_encounter_attributes_description]', @description)
    save_cmr(@browser)
    @browser.get_html_source.include?("2009-03-10").should be_true
    @browser.get_html_source.include?(@description).should be_true
  end

  it 'should add the encounter event form to it' do
    @browser.click("link=Edit Encounter")
    @browser.wait_for_page_to_load($load_time)

    add_form_to_event(@browser, @form_name).should be_true
    @browser.click("link=Edit Encounter")
    @browser.wait_for_page_to_load($load_time)
    @browser.get_html_source.include?(@form_name).should be_true
    @browser.get_html_source.include?(@question_text).should be_true
  end

    it 'should receive answers to disease-specific questions' do
      answer_investigator_question(@browser, @question_text, @question_answer)
      save_and_exit(@browser)
      @browser.get_html_source.include?(@question_text).should be_true
      @browser.get_html_source.include?(@question_answer).should be_true
    end

    it "should create another basic form for encounter events" do
      create_new_form_and_go_to_builder(@browser, @second_form_name, @disease, "All Jurisdictions", "Encounter Event").should be_true
      add_question_to_view(@browser, "Default View", {
          :question_text => @second_question_text,
          :data_type => 'Single line text',
          :short_name => get_random_word
        }).should be_true
      publish_form(@browser).should be_true
    end

    it 'should be possible for admins to push a form to an encounter event' do
      click_nav_forms(@browser).should be_true
      click_push_form(@browser, @second_form_name).should be_true
      click_nav_cmrs(@browser).should be_true
      click_resource_edit(@browser, 'cmrs', @cmr_last_name).should be_true
      @browser.click("link=Edit Encounter")
      @browser.wait_for_page_to_load($load_time)
      @browser.get_html_source.include?(@second_form_name).should be_true
      @browser.get_html_source.include?(@second_question_text).should be_true
    end
end
