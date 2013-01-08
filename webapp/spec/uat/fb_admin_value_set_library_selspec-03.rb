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

describe 'Form Builder Admin' do
  
  before(:all) do
    @form_name = get_unique_name(4) + " fb lib vs uat"
    @group_name = get_unique_name(3) + " grp vs-lib"
    
    @question_one_with_value_set = get_unique_name(3) + " q1 q vs-lib"
    @value_set_one_name = get_unique_name(3) + " q1 vs vs-lib"
    @value_set_one_value_one = get_unique_name(3) + " q1 v1 vs-lib"
    @value_set_one_value_two = get_unique_name(3) + " q1 v2 vs-lib"
    @value_set_one_value_three = get_unique_name(3) + " q1 v3 vs-lib"
    
    
    @question_two_with_value_set = get_unique_name(3) + " q2 q vs-lib"
    @value_set_two_name = get_unique_name(3) + " q2 vs vs-lib"
    @value_set_two_value_one= get_unique_name(3) + " q2 v1 vs-lib"
    @value_set_two_value_two= get_unique_name(3) + " q2 v2 vs-lib"
    @value_set_two_value_three = get_unique_name(3) + " q2 v3 vs-lib"
      
    @question_needing_value_set = get_unique_name(3) + " q3 q vs-lib"
  end
  
  after(:all) do
    @form_name = nil
    @group_name = nil
    
    @question_one_with_value_set = nil
    @value_set_one_name = nil
    @value_set_one_value_one = nil
    @value_set_one_value_two = nil
    @value_set_one_value_three = nil
    
    
    @question_two_with_value_set = nil
    @value_set_two_name = nil
    @value_set_two_value_one = nil
    @value_set_two_value_two = nil
    @value_set_two_value_three = nil
      
    @question_needing_value_set = nil
  end
  
  it 'should create a new form and go to builder' do
    create_new_form_and_go_to_builder(@browser, @form_name, "African Tick Bite Fever", "All Jurisdictions").should be_true
  end
  
  it 'should add two questions with value sets to the form' do
    
    add_question_to_view(@browser, "Default View", {
        :question_text => @question_one_with_value_set, 
        :data_type => "Drop-down select list",
        :short_name => get_random_word
      }
    ).should be_true

    add_value_set_to_question(@browser,
      @question_one_with_value_set,
      @value_set_one_name,
      [{ :name => @value_set_one_value_one }, { :name => @value_set_one_value_two }, { :name => @value_set_one_value_three }]
    ).should be_true
    
    add_question_to_view(@browser, "Default View", {
        :question_text => @question_two_with_value_set, 
        :data_type => "Drop-down select list", :short_name => get_random_word
      }
    ).should be_true

    add_value_set_to_question(@browser,
      @question_two_with_value_set,
      @value_set_two_name,
      [{ :name => @value_set_two_value_one }, { :name => @value_set_two_value_two }, { :name => @value_set_two_value_three }]
    ).should be_true
    
  end
  
  it 'should add a question that needs a value set' do
    add_question_to_view(@browser, "Default View", {
        :question_text => @question_needing_value_set, 
        :data_type => "Drop-down select list", :short_name => get_random_word
      }
    ).should be_true
  end
  
  it 'should add the first two value sets to the library' do
    add_value_set_to_library(@browser, @value_set_one_name, @group_name).should eql("OK")
    add_value_set_to_library(@browser, @value_set_two_name).should eql("OK")
  end
  
  it 'should add a value set from the library' do
    add_value_set_from_library_to_question(@browser, @question_needing_value_set, @value_set_one_name).should be_true
    num_times_text_appears(@browser, @value_set_one_name).should eql(2)
  end
  
end


