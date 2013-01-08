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

describe 'Form Builder Admin Standard Follow-Up Functionality' do
  
  before(:all) do
    @form_name = get_unique_name(2) + " fu-uat"
    @cmr_last_name = get_unique_name(1) + " fu-uat"
    @original_question_text = get_unique_name(2)  + " question fu-uat"
    @follow_up_question_text = get_unique_name(2)  + " question fu-uat"
    @follow_up_help_text = get_unique_name(10) + "help text fu-ust"
    @follow_up_answer =  get_unique_name(2)  + " answer fu-uat"    
  end
  
  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
    @original_question_text = nil
    @follow_up_question_text = nil
    @follow_up_help_text = nil
    @follow_up_answer =  nil
  end
  
  it 'should handle standard follow-ups.' do
    create_new_form_and_go_to_builder(@browser, @form_name, "African Tick Bite Fever", "All Jurisdictions")
    add_question_to_view(@browser, "Default View", {:question_text => @original_question_text, :data_type => "Single line text", :short_name => get_random_word})
    add_follow_up_to_question(@browser, @original_question_text, "Yes")
    add_question_to_follow_up(@browser, "Follow up, Condition: <b>Yes</b>", {:question_text => @follow_up_question_text, :data_type => "Single line text", :help_text => @follow_up_help_text, :short_name => get_random_word})
    publish_form(@browser)
    create_basic_investigatable_cmr(@browser, @cmr_last_name, "African Tick Bite Fever", "Bear River Health Department")
    
    edit_cmr(@browser)
    @browser.get_html_source.include?(@follow_up_question_text).should be_false
    
    # Enter the answer that meets the follow-up condition
    click_core_tab(@browser, INVESTIGATION)
    answer_investigator_question(@browser, @original_question_text, "Yes")

    @browser.click("link=#{@form_name}") # A bit of a kluge. Clicking this link essential generates the onChange needed to process the follow-up logic
    wait_for_element_present("//label[texte()='#@follow_up_question_text']")
    assert_tooltip_exists(@browser, @follow_up_help_text).should be_true
        
    # Enter an answer that does not meet the follow-up condition
    answer_investigator_question(@browser, @original_question_text, "No match")
    @browser.click("link=#{@form_name}")
    sleep(1)
    @browser.get_html_source.include?(@follow_up_question_text).should be_false
    
    # Back to a match, enter follow up answer and submit
    answer_investigator_question(@browser, @original_question_text, "Yes")
    @browser.click("link=#{@form_name}")
    wait_for_element_present("//label[texte()='#@follow_up_question_text']")
    answer_investigator_question(@browser, @follow_up_question_text, @follow_up_answer)

    save_cmr(@browser)    
    @browser.get_html_source.include?(@follow_up_answer).should be_true
    
    print_cmr(@browser).should be_true
    @browser.get_html_source.include?(@follow_up_question_text).should be_true
    @browser.get_html_source.include?(@follow_up_answer).should be_true
    @browser.close()
    @browser.select_window 'null'
    
    edit_cmr(@browser)
    # Enter an answer that does not meet the follow-up condition
    answer_investigator_question(@browser, @original_question_text, "No match")
    @browser.click("link=#{@form_name}")
    save_cmr(@browser)    
    @browser.get_html_source.include?(@follow_up_answer).should be_false
    
    print_cmr(@browser).should be_true
    @browser.get_html_source.include?(@follow_up_question_text).should be_false
    @browser.get_html_source.include?(@follow_up_answer).should be_false
    @browser.close()
    @browser.select_window 'null'
    
  end
    
end
