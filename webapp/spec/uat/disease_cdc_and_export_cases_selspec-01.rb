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
 
describe 'adding diseases' do
  
  # $dont_kill_browser = true
  
  before(:all) do
    @disease_name = get_unique_name(2)  << " da-uat"
  end
  
  after(:all) do
    @disease_name = nil
  end

  it 'should create an inactive disease' do
    navigate_to_disease_admin(@browser).should be_true
    @browser.click("//input[@value='Create new disease']")
    @browser.wait_for_page_to_load($load_time)
    create_disease(@browser, :disease_name => @disease_name).should be_true
  end

  it 'should have no cdc value' do
    @browser.click("link=Edit")
    @browser.wait_for_page_to_load($load_time)
    @browser.get_value("id=disease_cdc_code").should == ""
  end

  it 'should have no related export states' do
    case_checkboxes(@browser).each do |id|
      @browser.is_checked(id).should_not be_true
    end
  end
      

  it 'adding a cdc value should save the cdc export value' do
    modify_disease(@browser, :cdc_code => 11590)
    @browser.wait_for_page_to_load($load_time)
    @browser.click("link=Edit")
    @browser.wait_for_page_to_load($load_time)
    @browser.get_value("id=disease_cdc_code").should == '11590'
  end

  it 'selecting export states should store related export states' do
    checked_fields = {'Confirmed' => :check, 'Probable' => :check, 'Suspect' => :check}
    modify_disease(@browser, :external_codes => checked_fields)
    @browser.wait_for_page_to_load($load_time)
    @browser.click("link=Edit")
    @browser.wait_for_page_to_load($load_time)
    checked_fields.each { |id, msg| @browser.is_checked(id).should be_true }
  end
      

  it 'removing an export state should save preserve remaining export states' do
    unchecked_fields = {'Probable' => :uncheck}
    modify_disease(@browser, :external_codes => unchecked_fields)
    @browser.wait_for_page_to_load($load_time)
    @browser.click("link=Edit")
    @browser.wait_for_page_to_load($load_time)
    case_checkboxes(@browser).each do |id|
      @browser.is_checked(id).should == %w(Confirmed Suspect).include?(id)
    end
  end

end
