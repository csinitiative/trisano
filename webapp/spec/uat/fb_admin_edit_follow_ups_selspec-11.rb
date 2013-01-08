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

 #  $dont_kill_browser = true

describe 'Form Builder Admin Edit Follow-Up Functionality' do
  
  before(:all) do
    @form_name = get_unique_name(2) << " fue-uat"
    @cmr_last_name = get_unique_name(2) << " fue-uat"
    @question_for_follow_up = get_unique_name(2)  << " question fue-uat"
    @follow_up_question_text = get_unique_name(2)  << " fu question fue-uat"
    @core_follow_up_question_text = get_unique_name(2)  << " core fue question fue-uat"
  end
  
  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
    @question_for_follow_up = nil
    @follow_up_question_text = nil
    @core_follow_up_question_text = nil
  end
  
  it 'should create a form with edited followups' do
    create_new_form_and_go_to_builder(@browser, @form_name, "Hepatitis C, acute", "All Jurisdictions").should be_true
    
    add_core_follow_up_to_view(@browser, "Default View", "Code: Female (gender)", "Patient birth gender")
    add_question_to_follow_up(@browser, "Core follow up, Code condition: Female (gender)", {:question_text => @core_follow_up_question_text, :data_type => "Single line text", :short_name => get_random_word})
    
    add_question_to_view(@browser, "Default View", {:question_text => @question_for_follow_up, :data_type => "Single line text", :short_name => get_random_word})
    add_follow_up_to_question(@browser, @question_for_follow_up, "Yes")
    add_question_to_follow_up(@browser, "Follow up, Condition: <b>Yes</b>", {:question_text => @follow_up_question_text, :data_type => "Single line text", :short_name => get_random_word})
    edit_core_follow_up(@browser, "Core follow up, Code condition: Female (gender)", "Code: Yes (yesno)", "Died")
    edit_follow_up(@browser, "Follow up, Condition: <b>Yes</b>", "No")
    
    publish_form(@browser)
  end
  
  it 'should show edited followups on a new cmr' do  
    create_basic_investigatable_cmr(@browser, @cmr_last_name, "Hepatitis C, acute", "Bear River Health Department")
    edit_cmr(@browser)

    # Enter the answer that meets the core follow-up condition before the edit
    click_core_tab(@browser, DEMOGRAPHICS)
    @browser.is_element_present("//img[contains(@id, 'birth_gender_id')]").should be_false
    add_demographic_info(@browser, { :birth_gender => "Female" })
    @browser.get_html_source.include?(@core_follow_up_question_text).should be_false
    click_core_tab(@browser, "Investigation")

    # Enter the answer that meets the core follow-up condition after the edit
    click_core_tab(@browser, CLINICAL)
    add_clinical_info(@browser, { :died => "Yes" })
    wait_for_element_present("//label[text()='#@core_follow_up_question_text']", @browser)
    click_core_tab(@browser, "Investigation") 
    
    # Enter the answer that meets the follow-up condition before the edit
    answer_investigator_question(@browser, @question_for_follow_up, "Yes")
    #watch_for_answer_spinner(@question_for_follow_up) do
    #  @browser.click("link=#{@form_name}") # A bit of a kluge. Clicking this link essential generates the onChange needed to process the follow-up logic
    #end
    @browser.get_html_source.include?(@follow_up_question_text).should be_false
    
    # Enter the answer that meets the follow-up condition after the edit
    answer_investigator_question(@browser, @question_for_follow_up, "No")
    #watch_for_answer_spinner(@question_for_follow_up) do
    #  @browser.click("link=#{@form_name}") # A bit of a kluge. Clicking this link essential generates the onChange needed to process the follow-up logic
    #end
    wait_for_element_present("//label[text()='#@follow_up_question_text']", @browser)
  end
end
