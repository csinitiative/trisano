# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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
 
describe 'form builder core field configs for morbidity event multiples' do

  #$dont_kill_browser = true
  
  [{:name => 'Contacts', :tab_name => CONTACTS},
    {:name => 'Places', :tab_name => EPI},
    {:name => 'Treatments', :tab_name => CLINICAL}
  ].each do |test| 
  
    it "should support before and after on the '#{test[:name]}' multiples block" do
      form_name = get_unique_name(2) + " mmul_f"
      cmr_last_name = get_unique_name(1) + " mmul_f"
      disease_name = "Granuloma inguinale (GI)"
      jurisdiction = "Out of State"
      event_type = "Morbidity event"
      before_question = "b4 #{test[:name]} " + get_unique_name(2)
      after_question = "af #{test[:name]} " + get_unique_name(2)
      before_answer = "b4 #{test[:name]} answer" + get_unique_name(2)
      after_answer = "af #{test[:name]} answer" + get_unique_name(2)
      before_help_text = "b4 #{test[:name]} " + get_unique_name(10)
      after_help_text = "af #{test[:name]} " + get_unique_name(10)

      create_new_form_and_go_to_builder(@browser, form_name, disease_name, jurisdiction, event_type).should be_true
      add_core_field_config(@browser, test[:name])
      add_question_to_before_core_field_config(@browser, test[:name], {:question_text => before_question, :data_type => "Single line text", :help_text => before_help_text})
      add_question_to_after_core_field_config(@browser, test[:name], {:question_text => after_question, :data_type => "Single line text", :help_text => after_help_text})
      publish_form(@browser).should be_true
      
      create_basic_investigatable_cmr(@browser, cmr_last_name, disease_name, jurisdiction)
      edit_cmr(@browser).should be_true
      
      @browser.is_text_present(before_question).should be_true
      @browser.is_text_present(after_question).should be_true
      assert_tooltip_exists(@browser, before_help_text).should be_true
      assert_tooltip_exists(@browser, after_help_text).should be_true
      answer_investigator_question(@browser, before_question, before_answer)
      answer_investigator_question(@browser, after_question, after_answer)

      save_cmr(@browser)
      @browser.is_text_present(before_answer).should be_true
      @browser.is_text_present(after_answer).should be_true
      assert_tab_contains_question(@browser, test[:tab_name], before_question).should be_true
      assert_tab_contains_question(@browser, test[:tab_name], after_question).should be_true
      
      print_cmr(@browser).should be_true
      @browser.is_text_present(before_question).should be_true
      @browser.is_text_present(after_question).should be_true
      @browser.is_text_present(before_answer).should be_true
      @browser.is_text_present(after_answer).should be_true
      @browser.close()
      @browser.select_window 'null'
    end

  end
end
