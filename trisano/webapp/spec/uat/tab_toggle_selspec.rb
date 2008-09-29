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

describe 'Core tabs' do

  before :all do
    @browser.open '/trisano/cmrs/new'
    @browser.wait_for_page_to_load($load_time)
  end

  describe 'showing the new cmr page' do
    
    it 'should display disable tabs message' do
      @browser.is_visible("//span[@id='disable_tabs']").should be_true
    end

    it 'should display core tabs' do
      @browser.is_visible("//ul[@id='tabs']").should be_true
    end

    it 'should not display enable tabs message' do
      @browser.is_visible("//span[@id='enable_tabs']").should be_false
    end

    it 'should be able to click the enable tabs' do
      @browser.click("//span[@id='disable_tabs']")
    end
      
    it 'should hide the disable tabs message' do        
      @browser.is_visible("//span[@id='disable_tabs']").should be_false
    end
    
    it 'should hide the core tabs' do
      @browser.is_visible("//ul[@id='tabs']").should be_false
    end
    
    it 'should display enable tabs message' do
      @browser.is_visible("//span[@id='enable_tabs']").should be_true
    end

    it 'should be able to click enable tabs message' do
      @browser.click("//span[@id='enable_tabs']")
    end

    it 'should display disable tabs message' do
      @browser.is_visible("//span[@id='disable_tabs']").should be_true
    end

    it 'should display core tabs' do
      @browser.is_visible("//ul[@id='tabs']").should be_true
    end

    it 'should not display enable tabs message' do
      @browser.is_visible("//span[@id='enable_tabs']").should be_false
    end
    
  end

end
