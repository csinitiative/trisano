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

describe 'Form Builder Admin Question Alignment Functionality' do
  
  before(:all) do
    @form_name = get_unique_name(2) + " q-align-uat"
    @cmr_last_name = get_unique_name(1) + " q-align-uat"
    @question_text = get_unique_name(3) + " q-align-uat"
    @disease_name = get_random_disease
  end
  
  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
    @question_text = nil
    @disease_name = nil
  end
  
  it 'should handle standard follow-ups.' do
    create_new_form_and_go_to_builder(@browser, @form_name, @disease_name, "All Jurisdictions")
    @question_id = add_question_to_view(@browser, "Default View", {
        :question_text => @question_text, 
        :data_type => "Single line text", 
        :style => "Horizontal", :short_name => get_random_word
      }
    )
    
    publish_form(@browser)
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @disease_name, "Bear River Health Department")
    edit_cmr(@browser)
    
    @browser.get_html_source.include?(@question_text).should be_true
    published_question_id = get_question_investigate_div_id(@browser, @question_text)
    @browser.get_eval("window.document.getElementById(\"question_investigate_#{published_question_id}\").attributes[0].nodeValue").should eql("horiz")
  end
    
end