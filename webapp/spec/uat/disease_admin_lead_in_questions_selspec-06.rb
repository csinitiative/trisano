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
 
describe 'disease admin lead in questions' do
  
  # $dont_kill_browser = true
  
  before(:all) do
    @cmr_last_name = get_unique_name(1)  << " da-uat"
    @disease_name = get_unique_name(2)  << " da-uat"
    @contact_lead_in = get_unique_name(4)  << " da-uat"
    @place_lead_in = get_unique_name(4)  << " da-uat"
    @treatment_lead_in = get_unique_name(4)  << " da-uat"
  end
  
  after(:all) do
    @cmr_last_name = nil
    @disease_name = nil
    @contact_lead_in = nil
    @place_lead_in = nil
    @treatment_lead_in = nil
  end
  
  it 'should create a new disease' do
    navigate_to_disease_admin(@browser).should be_true
    @browser.click("//input[@value='Create new disease']")
    @browser.wait_for_page_to_load($load_time)
    create_disease(@browser, {
        :disease_name => @disease_name, 
        :contact_lead_in => @contact_lead_in, 
        :place_lead_in => @place_lead_in, 
        :treatment_lead_in => @treatment_lead_in,
        :disease_active =>  true
      }).should be_true
   
  end
    
  it "should create a CMR" do
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @disease_name, "Bear River Health Department").should be_true
  end
  
  it 'should display lead in questions in show mode' do
    @browser.get_html_source.include?(@contact_lead_in).should be_true
    @browser.get_html_source.include?(@place_lead_in).should be_true
    @browser.get_html_source.include?(@treatment_lead_in).should be_true
  end
  
  it 'should display lead in questions in print mode' do
    print_cmr(@browser).should be_true
    @browser.is_text_present(@contact_lead_in).should be_true
    @browser.is_text_present(@place_lead_in).should be_true
    @browser.is_text_present(@treatment_lead_in).should be_true
    @browser.close()
    @browser.select_window 'null'
  end
    
  it 'should display lead in questions in edit mode' do
    edit_cmr(@browser)
    html_source = @browser.get_html_source
    html_source.include?(@contact_lead_in).should be_true
    html_source.include?(@place_lead_in).should be_true
    html_source.include?(@treatment_lead_in).should be_true
  end

end
  
