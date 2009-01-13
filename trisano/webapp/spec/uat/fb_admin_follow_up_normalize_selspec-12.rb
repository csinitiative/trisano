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

describe 'Form Builder Admin Follow-Up Functionality' do

  before(:all) do
    @form_name = get_unique_name(2) + " fu-uat"
    @cmr_last_name = get_unique_name(1) + " fu-uat"
    @disease = get_random_disease

    @question_for_follow_up = get_unique_name(2)  + " question fu-uat"
    @follow_up_condition = "Yes"
    @follow_up_question_text = get_unique_name(2)  + " question fu-uat"
    @follow_up_answer =  get_unique_name(2)  + " answer fu-uat"

    @core_follow_up_condition = "eventname"
    @core_follow_up_question_text = get_unique_name(2)  + " question fu-uat"
    @core_follow_up_answer =  get_unique_name(2)  + " answer fu-uat"
  end

  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
    @disease = nil

    @question_for_follow_up = nil
    @follow_up_condition = nil
    @follow_up_question_text = nil
    @follow_up_answer = nil

    @core_follow_up_condition = nil
    @core_follow_up_question_text = nil
    @core_follow_up_answer = nil
  end

  it 'should handle adding follow-ups to core fields and form builder questions.' do
    create_new_form_and_go_to_builder(@browser, @form_name, @disease, "All Jurisdictions").should be_true

    add_question_to_view(@browser, "Default View", {:question_text => @question_for_follow_up, :data_type => "Single line text"})
    add_follow_up_to_question(@browser, @question_for_follow_up, @follow_up_condition)
    add_question_to_follow_up(@browser, "Follow up, Condition: <b>#{@follow_up_condition}</b>", {:question_text => @follow_up_question_text, :data_type => "Single line text"})

    add_core_field_config(@browser, "Outbreak")
    add_core_follow_up_to_after_core_field(@browser, "Outbreak", "  #{@core_follow_up_condition}  ", "Outbreak")
    add_question_to_follow_up(@browser, "Core follow up, <b>#{@core_follow_up_condition}</b>", {:question_text => @core_follow_up_question_text, :data_type => "Single line text"})

    publish_form(@browser)
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @disease, "Bear River Health Department")
  end

  it "should add an event name with extra whitespace and capitalization" do
    edit_cmr(@browser)
    @browser.is_text_present(@follow_up_question_text).should be_false

    # Enter the answer that meets the follow-up condition, but with a different case and extra padding
    click_core_tab(@browser, INVESTIGATION)
    answer_investigator_question(@browser, @question_for_follow_up, "   yEs    ")

    watch_for_answer_spinner(@question_for_follow_up) do
      click_core_tab(@browser, INVESTIGATION) # Kluge to get the spinner to show up
    end

    @browser.is_text_present(@follow_up_question_text).should be_true
    answer_investigator_question(@browser, @follow_up_question_text, @follow_up_answer)
    save_cmr(@browser)
    click_core_tab(@browser, INVESTIGATION)
    @browser.is_text_present(@follow_up_answer).should be_true
  end

  it "should add an event name with extra whitespace and capitalization" do
    edit_cmr(@browser)
    @browser.is_text_present(@core_follow_up_question_text).should be_false
    
    # Enter the answer that meets the follow-up condition, but with a different case and extra padding
    click_core_tab(@browser, ADMIN)
    watch_for_core_field_spinner('outbreak_name') do
      @browser.type("morbidity_event[outbreak_name]", "       eVentName          ")
    end

    @browser.is_text_present(@core_follow_up_question_text).should be_true
    answer_investigator_question(@browser, @core_follow_up_question_text, @core_follow_up_answer)
    save_cmr(@browser)
    click_core_tab(@browser, ADMIN)
    @browser.is_text_present(@core_follow_up_answer).should be_true
  end

end

