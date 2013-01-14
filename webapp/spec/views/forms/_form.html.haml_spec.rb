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

describe "/forms/_form.html.haml" do

  before do
    @form = Factory.build(:form)
    @form.save_and_initialize_form_elements
    assigns[:form] = @form
    @f = mock
    @f.stubs(:label)
    @f.stubs(:text_field)
    @f.stubs(:check_box)
    @f.stubs(:select)
    @f.stubs(:collection_select)
    @f.stubs(:object).returns(@form)
  end

  it "renders with short name editable" do
    @f.expects(:text_field).with(:short_name)
    render "forms/_form.html.haml", :locals => {:f => @f}
  end

  it "renders with short name *not* editable" do
    @form.stubs(:short_name_editable?).returns(false)
    render "forms/_form.html.haml", :locals => {:f => @f}
    assert_select 'td', /#{@form.short_name}/
  end

end
