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

require File.dirname(__FILE__) + './spec_helper'

# $dont_kill_browser = true

describe 'Form Builder Admin' do
  
  before(:all) do
    @form_name = "Benchmark Form " + get_unique_name(2)
    @start_time = Time.new
    @group_prefix =  get_unique_name(2)
  end
  
  after(:all) do
    @form_name = nil
  end
  
  it 'should create an investigator form with 200 questions, 100 of which get added to the library, into 20 different groups' do
    create_new_form_and_go_to_builder(@browser, @form_name, "African Tick Bite Fever", "All Jurisdictions")
    
    (1..20).each do |section_count|
      section_name = "Section #{section_count}"
      section_group = "#{@group_prefix} #{section_count}"
      
      add_section_to_view(@browser, 'Default View', section_name)
      
      (1..5).each do |question_count|
        question_text = "Single line question #{section_count} -- #{question_count}"
        add_question_to_section(@browser, section_name, {
            :question_text => question_text, 
            :data_type => "Single line text"}
        )
        
        
      end
      
      (1..5).each do |question_count|
        question_text = "Drop-down select question #{section_count} -- #{question_count}"
        add_question_to_section(@browser, section_name, {
            :question_text => question_text, 
            :data_type => "Drop-down select list"}
        )
        add_value_set_to_question(@browser, question_text, "Yes/No/Maybe", "Yes", "No", "Maybe") 
        add_question_to_library(@browser, question_text, section_group)
      end
    end
  end
    
  it 'should publish it five times' do
    
    (1..5).each do |count|
      publish_form(@browser).should be_true
      click_build_form(@browser, @form_name)
    end
    
  end
  
end