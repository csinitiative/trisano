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

describe 'Adding help text to form builder questions' do
  
  before :each do
    @form_name = get_unique_name(2)  << " hlp-uat"
    @question_text = get_unique_name(2)  << " hlp-uat"
    @help_text = get_unique_name(10) << " hlp-uat"
    @cmr_last_name = get_unique_name(1)  << " hlp-uat"
  end

  after :each do
    @form_name = nil
    @question_text = nil
    @help_text = nil
    @cmr_last_name = nil
  end

  describe 'on the default investigation tab' do
    
    [{:data_type => "Single line text", :disease => 'African Tick Bite Fever'},
     {:data_type => "Multi-line text", :disease => 'AIDS'},
     {:data_type => "Drop-down select list", :disease => 'Amebiasis'},
     {:data_type => "Radio buttons", :disease => 'Bacterial meningitis, other'},
     {:data_type => "Checkboxes", :disease => 'Anaplasma phagocytophilum'},
     {:data_type => "Date", :disease => 'Anthrax'},
     {:data_type => "Phone Number", :disease => 'Aseptic meningitis'}
    ].each do |test_case|
    
      it "should create a #{test_case[:data_type]} question w/ help text" do
        create_new_form_and_go_to_builder(@browser, @form_name, test_case[:disease], 'All Jurisdictions', 'Morbidity event').should be_true
        add_question_to_view(@browser, "Default View", {:question_text => @question_text, :data_type => test_case[:data_type], :help_text => @help_text})
        publish_form(@browser).should be_true

        # go looking for the help
        create_basic_investigatable_cmr(@browser, @cmr_last_name, test_case[:disease], 'Summit County Public Health Department').should be_true
        edit_cmr(@browser).should be_true
        click_core_tab(@browser, 'Investigation')
        assert_tooltip_exists(@browser, @help_text).should be_true
      end
    end

  end

end
