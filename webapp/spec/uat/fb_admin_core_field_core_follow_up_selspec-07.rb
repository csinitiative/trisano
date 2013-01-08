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

describe 'Form Builder Admin Core-Field Core-Follow-Up Functionality' do

  before(:all) do
    @form_name = get_unique_name(2) + " cffu-uat"
    @cmr_last_name = get_unique_name(1) + " cffu-uat"
    @follow_up_question_text = get_unique_name(2)  + " question cffu-uat"
    @follow_up_answer =  get_unique_name(2)  + " answer cffu-uat"
  end

  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
    @follow_up_question_text = nil
    @follow_up_answer =  nil
  end

  it 'should handle adding follow-ups to core fields.' do
    create_new_form_and_go_to_builder(@browser, @form_name, "African Tick Bite Fever", "All Jurisdictions").should be_true
    add_core_field_config(@browser, "Patient birth gender")
    add_core_follow_up_to_after_core_field(@browser, "Patient birth gender", "Code: Female (gender)", "Patient birth gender")
    add_question_to_follow_up(@browser, "Core follow up, Code condition: Female (gender)", {:question_text => @follow_up_question_text, :data_type => "Single line text", :short_name => get_random_word})
    publish_form(@browser)
    create_basic_investigatable_cmr(@browser, @cmr_last_name, "African Tick Bite Fever", "Bear River Health Department")
    edit_cmr(@browser)
    @browser.is_text_present(@follow_up_question_text).should be_false

    # Enter the answer that meets the follow-up condition
    click_core_tab(@browser, DEMOGRAPHICS)
    add_demographic_info(@browser, { :birth_gender => "Female" })
    @browser.wait_for_ajax
    @browser.is_text_present(@follow_up_question_text).should be_true

    # Enter an answer that does not meet the follow-up condition
    watch_for_core_field_spinner('birth_gender_id') do
      add_demographic_info(@browser, { :birth_gender => "Male" })
    end
    @browser.is_text_present(@follow_up_question_text).should be_false

    # Back to a match, enter follow up answer and submit
    watch_for_core_field_spinner('birth_gender_id') do
      add_demographic_info(@browser, { :birth_gender => "Female" })
    end
    answer_investigator_question(@browser, @follow_up_question_text, @follow_up_answer)

    save_cmr(@browser)
    click_core_tab(@browser, "Investigation")
    @browser.get_html_source.include?(@follow_up_answer).should be_true
    edit_cmr(@browser)

    # Enter an answer that does not meet the follow-up condition
    add_demographic_info(@browser, { :birth_gender => "Male" })
    sleep(7)

    save_cmr(@browser)
    click_core_tab(@browser, "Investigation")
    @browser.get_html_source.include?(@follow_up_answer).should be_false
  end
end

