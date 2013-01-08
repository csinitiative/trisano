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

describe 'invalid cmr' do
  #$dont_kill_browser = true
  
  before(:all) do
    @browser.open "/trisano/cmrs/new"
    @browser.wait_for_page_to_load
  end

  it 'should preserve the reporting agency field data' do
    add_reporting_info(@browser, { :name => "The Venture Compound", :place_type => "S" })
    save_and_continue(@browser)
    click_core_tab(@browser, REPORTING)
    @browser.get_value("//input[@id='morbidity_event_reporting_agency_attributes_place_entity_attributes_place_attributes_name']").should == 'The Venture Compound'
    @browser.is_checked("//div[@id='reporting_agency']//input[contains(@id, '_S')]").should == true
  end
end
