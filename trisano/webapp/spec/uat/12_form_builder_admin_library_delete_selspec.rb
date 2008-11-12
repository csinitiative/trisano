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

describe 'Form Builder Admin' do
  
  before(:all) do
    @form_name = get_unique_name(4) + " fb lib uat"
    @group_name = get_unique_name(3) + " grp fb lib"
    @group_question_text = get_unique_name(3) + " q1 fb lib"
    @no_group_question_text = get_unique_name(3) + " q2 fb lib"
  end
  
  after(:all) do
    @form_name = nil
    @group_name = nil
    @group_question_text = nil
    @no_group_question_text  = nil
  end
  
  it 'should create a new form and add questions to the library' do
    create_new_form_and_go_to_builder(@browser, @form_name, "African Tick Bite Fever", "All Jurisdictions")
    add_question_to_view(@browser, "Default View", {:question_text => @no_group_question_text, :data_type => "Single line text"})
    add_question_to_library(@browser, @no_group_question_text)
    add_question_to_view(@browser, "Default View", {:question_text => @group_question_text, :data_type => "Single line text"})
    add_question_to_library(@browser, @group_question_text, @group_name)
  end
  
  it 'should delete the questions used for copying to avoid collisions during the next example' do
    delete_question(@browser, @no_group_question_text).should be_true
    delete_question(@browser, @group_question_text).should be_true
  end
  
  it 'should delete the questions from the library' do
    open_form_builder_library_admin(@browser).should be_true    
    delete_question(@browser, @no_group_question_text).should be_true
    delete_question(@browser, @group_question_text).should be_true
  end
  
end