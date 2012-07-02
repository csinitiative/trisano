# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

require File.dirname(__FILE__) + '/../spec_helper'

# $dont_kill_browser = true

describe 'Form Builder Admin' do
  
  before(:all) do
  end
  
  after(:all) do
  end
  
  it 'should create an investigator form with 100 questions' do
    create_new_form_and_go_to_builder(@browser, "Benchmark Form", "African Tick Bite Fever", "All Jurisdictions")
    
    (1..10).each do |section_count|
      section_name = "Section #{section_count}"
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
      end
    end
  end
  
  it 'should create core field configurations' do
    
    # Debt: Duplicating the exposed attributes here for now.
    {
      "morbidity_event[active_patient][active_primary_entity][person][last_name]" => {:type => :single_line_text, :name => "Patient last name" },
      "morbidity_event[active_patient][active_primary_entity][person][first_name]" => {:type => :single_line_text, :name => "Patient first name" },
      "morbidity_event[active_patient][active_primary_entity][person][middle_name]" => {:type => :single_line_text, :name => "Patient middle name" },
      "morbidity_event[active_patient][active_primary_entity][address][street_number]" => {:type => :single_line_text, :name => "Patient street number" },
      "morbidity_event[active_patient][active_primary_entity][address][street_name]" => {:type => :single_line_text, :name => "Patient street name" },
      "morbidity_event[active_patient][active_primary_entity][address][unit_number]" => {:type => :single_line_text, :name => "Patient unit number" },
      "morbidity_event[active_patient][active_primary_entity][address][city]" => {:type => :single_line_text, :name => "Patient city" },
      "morbidity_event[active_patient][active_primary_entity][address][state_id]" => {:type => :single_line_text, :name => "Patient state" },
      "morbidity_event[active_patient][active_primary_entity][address][county_id]" => {:type => :single_line_text, :name => "Patient county" },
      "morbidity_event[active_patient][active_primary_entity][address][postal_code]" => {:type => :single_line_text, :name => "Patient zip code" },
      "morbidity_event[active_patient][active_primary_entity][person][birth_date]" => {:type => :date, :name => "Patient date of birth" },
      "morbidity_event[active_patient][active_primary_entity][person][approximate_age_no_birthday]" => {:type => :single_line_text, :name => "Patient age" },
      "morbidity_event[active_patient][active_primary_entity][person][date_of_death]" => {:type => :date, :name => "Patient date of death" },
      "morbidity_event[active_patient][active_primary_entity][telephone][area_code]" => {:type => :single_line_text, :name => "Patient area code" },
      "morbidity_event[active_patient][active_primary_entity][telephone][phone_number]" => {:type => :single_line_text, :name => "Patient phone number" },
      "morbidity_event[active_patient][active_primary_entity][telephone][extension]" => {:type => :single_line_text, :name => "Patient extension" },
      "morbidity_event[active_patient][active_primary_entity][person][birth_gender_id]" => {:type => :single_line_text, :name => "Patient birth gender" },
      "morbidity_event[active_patient][active_primary_entity][person][ethnicity_id]" => {:type => :single_line_text, :name => "Patient ethnicity" },
      "emorbidity_vent[active_patient][active_primary_entity][person][primary_language_id]" => {:type => :single_line_text, :name => "Patient primary language" }
    }.each do |key, value|
      add_core_field_config(@browser, value[:name])
      add_question_to_core_field_config(@browser, value[:name], {:question_text => "#{value[:name]} question?", :data_type => "Single line text"})
    end
  end
  
end
