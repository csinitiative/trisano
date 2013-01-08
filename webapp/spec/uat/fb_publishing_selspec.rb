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

describe 'Publishing a form with a short name that is already active' do

  before(:all) do
    @form_one_name = get_unique_name(2) + " cffu-uat"
    @short_name = @form_one_name
    @form_two_name = get_unique_name(1) + " cffu-uat"
  end

  it 'should fail w/ a error message' do
    create_new_form_and_go_to_builder(@browser, @form_one_name, "African Tick Bite Fever", "All Jurisdictions").should be_true
    publish_form(@browser).should be_true
    click_deactivate_form(@browser, @form_one_name).should be_true

    # try to re-use the short name
    create_new_form_and_go_to_builder(@browser, @form_two_name, "African Tick Bite Fever", "All Jurisdictions", "Morbidity Event", @form_one_name).should be_true
    publish_form(@browser).should be_true

    #now go back and try to publish to deactivated form
    click_build_form(@browser, @form_one_name)
    publish_form_failure.should be_true
  end
end
