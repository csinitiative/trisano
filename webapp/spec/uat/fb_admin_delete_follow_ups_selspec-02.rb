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

require File.dirname(__FILE__) << '/spec_helper'

# $dont_kill_browser = true

describe 'Form Builder Admin Delete Follow-Up Functionality' do
  
  before(:all) do
    @form_name = get_unique_name(2) << " fud-uat"
    @cmr_last_name = get_unique_name(2) << " fud-uat"
    @question_for_follow_up = get_unique_name(2)  << " question fud-uat"
    @follow_up_question_text = get_unique_name(2)  << " fu question fud-uat"
    @core_follow_up_question_text = get_unique_name(2)  << " core fu question fud-uat"
    @patient_disease = get_random_disease
  end
  
  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
    @question_for_follow_up = nil
    @follow_up_question_text = nil
    @core_follow_up_question_text = nil
    @patient_disease = nil
  end
  
  it 'should handle core follow-ups.' do
    create_new_form_and_go_to_builder(@browser, @form_name, @patient_disease, "All Jurisdictions").should be_true
    
    add_core_follow_up_to_view(@browser, "Default View", "Code: Female (gender)", "Patient birth gender")
    add_question_to_follow_up(@browser, "Core follow up, Code condition: Female (gender)", {:question_text => @core_follow_up_question_text, :data_type => "Single line text", :short_name => get_random_word})
    
    add_question_to_view(@browser, "Default View", {:question_text => @question_for_follow_up, :data_type => "Single line text", :short_name => get_random_word})
    add_follow_up_to_question(@browser, @question_for_follow_up, "Yes")
    add_question_to_follow_up(@browser, "Follow up, Condition: <b>Yes</b>", {:question_text => @follow_up_question_text, :data_type => "Single line text", :short_name => get_random_word})
    
    delete_follow_up(@browser, "Core follow up, Code condition: Female (gender)").should be_true
    delete_follow_up(@browser, "Follow up, Condition: <b>Yes</b>").should be_true
    
    publish_form(@browser)
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @patient_disease, "Bear River Health Department")
    edit_cmr(@browser)

    # Enter the answer that meets the core follow-up condition
    add_demographic_info(@browser, { :birth_gender => "Female" })
    click_core_tab(@browser, "Investigation") # This click triggers the onChange that triggers the condition processing
    sleep(2) # Replace this with something better -- need to make sure the round trip to process condition has happened
    @browser.get_html_source.include?(@core_follow_up_question_text).should be_false
    
    # Enter the answer that meets the follow-up condition
    answer_investigator_question(@browser, @question_for_follow_up, "Yes")
    @browser.click("link=#{@form_name}") # A bit of a kluge. Clicking this link essential generates the onChange needed to process the follow-up logic
    sleep(2) # Replace this with something better -- need to make sure the round trip to process condition has happened
    @browser.get_html_source.include?(@follow_up_question_text).should be_false

  end
end
