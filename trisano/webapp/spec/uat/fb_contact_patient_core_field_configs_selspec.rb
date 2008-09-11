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
 
describe 'form builder patient-level core field configs for contacts' do
  
  # $dont_kill_browser = true
  
  [{:name => 'Contact last name', :tab_name => DEMOGRAPHICS},
    {:name => 'Contact first name', :tab_name => DEMOGRAPHICS},
    {:name => 'Contact middle name', :tab_name => DEMOGRAPHICS},
    {:name => 'Contact date of birth', :tab_name => DEMOGRAPHICS},
    {:name => 'Contact age', :tab_name => DEMOGRAPHICS},
    {:name => 'Contact date of death', :tab_name => CLINICAL},
    {:name => 'Contact birth gender', :tab_name => DEMOGRAPHICS},
    {:name => 'Contact ethnicity', :tab_name => DEMOGRAPHICS},
    {:name => 'Contact primary language', :tab_name => DEMOGRAPHICS}
  ].each do |test| 
  
    it "should support before and after on the '#{test[:name]}' field" do
      form_name = get_unique_name(2) + " cpl_f"
      cmr_last_name = get_unique_name(1) + " cpl_f"
      contact_last_name = get_unique_name(1) + " cpl_f"
      disease_name = "Lead poisoning"
      jurisdiction = "Out of State"
      event_type = "Contact event"
      before_question = "b4 #{test[:name]} " + get_unique_name(2)
      after_question = "af #{test[:name]} " + get_unique_name(2)
      before_answer = "b4 #{test[:name]} answer" + get_unique_name(2)
      after_answer = "af #{test[:name]} answer" + get_unique_name(2)

      create_new_form_and_go_to_builder(@browser, form_name, disease_name, jurisdiction, event_type).should be_true
      add_core_field_config(@browser, test[:name])
      add_question_to_before_core_field_config(@browser, test[:name], {:question_text => before_question, :data_type => "Single line text"})
      add_question_to_after_core_field_config(@browser, test[:name], {:question_text => after_question, :data_type => "Single line text"})
      publish_form(@browser).should be_true
      
      create_basic_investigatable_cmr(@browser, cmr_last_name, disease_name, jurisdiction)
      edit_cmr(@browser).should be_true
      add_contact(@browser, {:last_name => contact_last_name, :first_name => "John", :disposition => "Unable to locate"})
      save_cmr(@browser).should be_true
      click_link_by_order(@browser, "edit-contact-event", 1)
      @browser.wait_for_page_to_load($load_time)
      
      @browser.is_text_present(before_question).should be_true
      @browser.is_text_present(after_question).should be_true
      answer_investigator_question(@browser, before_question, before_answer)
      answer_investigator_question(@browser, after_question, after_answer)

      save_contact_event(@browser)
      @browser.is_text_present(before_answer).should be_true
      @browser.is_text_present(after_answer).should be_true
      assert_tab_contains_question(@browser, test[:tab_name], before_question).should be_true
      assert_tab_contains_question(@browser, test[:tab_name], after_question).should be_true
    end

  end
end
