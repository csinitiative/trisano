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

describe 'Form Builder Admin Invalid Core Follow-ups' do

  before(:all) do
    @form_name = get_unique_name(2) + " ifu-uat"
    @cmr_last_name = get_unique_name(1) + " ifu-uat"
  end

  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
    end

  it 'should add a group to the form' do
    create_new_form_and_go_to_builder(@browser, @form_name, "African Tick Bite Fever", "All Jurisdictions")
    add_invalid_core_follow_up_to_view(@browser, "Default View", "Code: Female (gender)", "event[I][do][not][exist]")
    @browser.is_text_present "invalid core field path: event[I][do][not][exist]"
  end

end
