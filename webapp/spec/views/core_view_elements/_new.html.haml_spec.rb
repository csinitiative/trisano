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

require File.dirname(__FILE__) + '/../../spec_helper'

describe "/core_view_elements/_new.html.haml" do

  before do
    @core_view_element = Factory.create(:core_view_element)
  end

  it "renders with available core fields" do
    assigns[:available_core_views] = [mock]

    render "core_view_elements/_new.html.haml", {
      :locals => {
        :core_view_element => @core_view_element } }
    response.should_not have_tag('b', I18n.t(:no_core_fields))
  end

  it "renders message is available core fields is empty" do
    assigns[:available_core_views] = []

    render "core_view_elements/_new.html.haml", {
      :locals => {
        :core_view_element => @core_view_element } }
    response.should have_tag('b', I18n.t(:no_core_views))
  end

end
