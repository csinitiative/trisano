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

describe "/forms/show.html.haml" do

  before do
    @form = Factory.build(:form)
    @form.save_and_initialize_form_elements
  end

  it "renders template" do
    assigns[:form] = @form
    render "forms/show.html.haml"
    response.should have_tag('a', I18n.t(:edit))
  end

  it "renders form" do
    assigns[:form] = @form.publish
    render "forms/show.html.haml"
    response.should_not have_tag('a', I18n.t(:edit))
  end

end
