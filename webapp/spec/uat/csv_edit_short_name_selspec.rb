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

describe 'CSV configuration' do

 # $dont_kill_browser = true

  before :all do
    @browser.open "/trisano/cmrs"
    @unique_name = get_unique_name(1)
    @unique_name = @unique_name[0..10] if @unique_name.size > 10
  end

  it 'should open csv config page' do
    click_nav_admin(@browser)
    @browser.click("//a[@id='admin_csv_config']")
    @browser.wait_for_page_to_load
  end

  it 'should edit short names from csv records' do
    @browser.click("//table[@id='morbidity_event_fields']//td[contains(text(), 'patient_event_id')]/../td[2]/div/a")
    wait_for_element_present("//form[contains(@id, '-inplaceeditor')]")
    @browser.type("//input[@class='editor_field']", @unique_name)
    @browser.click("//input[@class='editor_ok_button']")
    wait_for_element_not_present("//form[contains(@id, '-inplaceeditor')]")
    # Needs some assertions
  end

end
