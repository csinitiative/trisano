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

describe 'Form Builder Admin Short Name' do
  
  before(:all) do
    @form_name = get_unique_name(2) + " short-uat"
    @original_question_text = get_unique_name(2)  + " question short-uat"
    @short_name_text = get_unique_name(2)  + " sn"
  end
  
  after(:all) do
    @form_name = nil
    @original_question_text = nil
  end
  
  it 'should allow for short name entry' do
    create_new_form_and_go_to_builder(@browser, @form_name, "African Tick Bite Fever", "All Jurisdictions").should be_true
    add_question_to_view(@browser, "Default View", { :question_text => @original_question_text,
        :data_type => "Single line text", 
        :short_name => @short_name_text
      }).should be_true

    @browser.is_text_present(@short_name_text.gsub(' ', '_')).should be_true
    
  end
    
end
