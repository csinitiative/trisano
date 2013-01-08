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
 
describe 'adding and activating diseases' do
  
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

  it 'should appear inactive in disease index' do
    navigate_to_disease_admin(@browser).should be_true
    is_disease_inactive(@browser, @disease_name).should be_true 
  end

  it 'inactive diseases should not appear in disease list for new cmrs' do
    click_nav_new_cmr(@browser)
    @browser.get_select_options("//div[@id='disease_info_form']//select[contains(@id, '_disease_id')]").include?(@disease_name).should_not be_true
  end

  it 'should activate disease from admin screen' do
    navigate_to_disease_admin(@browser).should be_true
    edit_disease(@browser, @disease_name, :disease_active => true)
  end

  it 'should appear active in th disease index' do
    navigate_to_disease_admin(@browser).should be_true
    is_disease_active(@browser, @disease_name).should be_true 
  end

  it 'active diseases should appear in the disease list for new cmrs' do
    click_nav_new_cmr(@browser)
    @browser.get_select_options("//div[@id='disease_info_form']//select[contains(@id, '_disease_id')]").include?(@disease_name).should be_true
  end

end
  
