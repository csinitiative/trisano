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

describe 'Adding multiple hospitals to a CMR' do

  it "should allow adding new hospitals to a new CMR" do
    @browser.open "/trisano/cmrs"
    click_nav_new_cmr(@browser)
    add_demographic_info(@browser, { :last_name => "Hospital-HF", :first_name => "Johnny" })
    first_reported_to_ph_date @browser, Date.today
    add_hospital(@browser, { :name => "Allen Memorial Hospital" }, 1)
    add_hospital(@browser, { :name => "Gunnison Valley Hospital" }, 2)
    save_cmr(@browser).should be_true
    @browser.is_text_present('Allen Memorial Hospital').should be_true
    @browser.is_text_present('Gunnison Valley Hospital').should be_true
  end

  it "should allow removing a hospital" do
    edit_cmr(@browser)
    remove_hospital(@browser)
    save_cmr(@browser).should be_true
    @browser.is_text_present('Allen Memorial Hospital').should_not be_true
  end

  it "should allow editing a hospital" do
    edit_cmr(@browser)
    add_hospital(@browser, { :name => "Alta View Hospital" }, 1)
    save_cmr(@browser).should be_true
    @browser.is_text_present('Alta View Hospital').should be_true
  end

end
