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

#$dont_kill_browser = true

describe 'Tab Toggling Functionality' do

  it 'should toggle New CMR tabs properly' do
    @browser.open '/trisano/cmrs'
    click_nav_new_cmr(@browser).should be_true
    verify_tab_behavior(@browser)
  end

  it 'should show CMR Core tabs properly' do
    create_basic_investigatable_cmr(@browser, 'Biel', 'AIDS', 'TriCounty Health Department').should be_true
    verify_tab_behavior(@browser)
  end

  it 'should show Edit Place Exposure tabs properly' do
    edit_cmr(@browser).should be_true
    add_place(@browser, { :name => "Davis Natatorium", :place_type => "P" })
    save_cmr(@browser).should be_true
    edit_place(@browser).should be_true
    verify_tab_behavior(@browser)
  end

  it 'should show Show Place Exposure tabs properly' do
    @browser.click "link=Show"
    @browser.wait_for_page_to_load($load_time)
    verify_tab_behavior(@browser)
  end

  it 'should show Edit Contact Event tabs properly' do
    click_nav_new_cmr(@browser).should be_true
    add_demographic_info(@browser, { :last_name => "Headroom", :first_name => "Max" })
    first_reported_to_ph_date @browser, Date.today
    add_contact(@browser, { :last_name => "Costello", :first_name => "Lou", :disposition => "Unable to locate" })
    add_contact(@browser, {
        :last_name => "Abbott",
        :first_name => "Bud",
        :disposition => "Other" ,
        :area_code => "202",
        :phone_number => "5551212",
        :extension => "22"
      }, 2)
    save_cmr(@browser).should be_true
    edit_contact_event(@browser)
    verify_tab_behavior(@browser)
  end

  it 'should show Show Contact Event tabs properly' do
    @browser.click "link=Show"
    @browser.wait_for_page_to_load($load_time)
    verify_tab_behavior(@browser)
  end
end

def verify_tab_behavior(browser)
  browser.is_visible("//span[@id='disable_tabs']").should be_true
  browser.is_visible("//ul[@id='tabs']").should be_true
  browser.is_visible("//span[@id='enable_tabs']").should be_false
  browser.click("//span[@id='disable_tabs']")
  browser.is_visible("//span[@id='disable_tabs']").should be_false
  browser.is_visible("//ul[@id='tabs']").should be_false
  browser.is_visible("//span[@id='enable_tabs']").should be_true
  browser.click("//span[@id='enable_tabs']")
  browser.is_visible("//span[@id='disable_tabs']").should be_true
  browser.is_visible("//ul[@id='tabs']").should be_true
  browser.is_visible("//span[@id='enable_tabs']").should be_false
end
