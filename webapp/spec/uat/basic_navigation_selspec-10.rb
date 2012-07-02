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

require File.dirname(__FILE__) + '/spec_helper'

  describe 'The TriSano home page' do 

    before :each do
      @browser.open "/trisano/events"
      @browser.wait_for_page_to_load($load_time)
    end
    
    it 'should have links to all the sub-pages' do
      @browser.is_text_present('EVENTS').should be_true
      @browser.is_text_present('NEW CMR').should be_true
      @browser.is_text_present('SEARCH').should be_true
      @browser.is_text_present('ADMIN').should be_true
    end
    
    it 'should have a logo on the home page' do
      #Then check for the various text lables on the home page
      @browser.is_element_present('//img[@alt=\'Logo\']').should be_true
    end
    
    it 'should correctly identify the user' do
      @browser.is_text_present('default_user').should be_true
    end

    it 'should navigate successfully to the home page' do    
      @browser.click '//img[@alt=\'Logo\']'
      @browser.wait_for_page_to_load($load_time)
      @browser.is_text_present('Welcome to TriSano').should be_true
    end
    
    it 'should navigate successfully to the Admin page' do
      click_nav_admin(@browser).should be_true
    end

    it 'should navigate successfully to the Event Search page' do
      click_nav_search(@browser).should be_true
      @browser.is_text_present('Event Search').should be_true
    end
    
    it 'should navigate successfully to the View CMRs page' do
      click_nav_cmrs(@browser).should be_true
    end
    
    it 'should navigate successfully to the New CMR page' do
      click_nav_new_cmr(@browser).should be_true
    end
    
    it 'should navigate successfully to the Forms page' do
      click_nav_forms(@browser).should be_true
    end
    
    it 'should navigate successfully to the Users page' do
      click_nav_admin(@browser).should be_true
      @browser.click('id=admin_users')
      @browser.wait_for_page_to_load($load_time)
      @browser.is_text_present('Users').should be_true
    end
  end

