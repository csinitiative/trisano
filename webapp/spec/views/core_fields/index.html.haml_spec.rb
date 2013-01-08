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

require File.dirname(__FILE__) + '/../../spec_helper'

describe "/core_fields/index.html.haml" do

  before :all do
    given_core_fields_loaded_for(:morbidity_event)
    CoreField.find_by_key('morbidity_event[parent_guardian]').update_attributes(:disease_specific => true)
  end

  before do
    assigns[:core_fields] = CoreField.roots
    render "/core_fields/index.html.haml"
  end

  it "displays core fields' name" do
    response.should have_tag('div.formname a', 'Patient last name')
  end

  it "shows if core field is required" do
    response.should have_tag('div.required', 'Required')
  end

  it "shows if core field is required for the section" do
    response.should have_tag('div.required_if_others', 'Required for Section')
  end

  it "shows a 'Display' button for hidden fields" do
    response.should have_tag('.button a.display', 'Display')
  end

  it "shows a 'Hide' button for displayed fields" do
    response.should have_tag('.button a.hide', 'Hide')
  end

end
