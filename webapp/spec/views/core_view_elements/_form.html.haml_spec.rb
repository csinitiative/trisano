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

describe "/core_view_elements/_form.html.haml" do

  before do
    @f = mock
    @f.expects(:hidden_field).with(:parent_element_id)
    @f.stubs(:select)
  end

  it "renders with available core views" do
    assigns[:available_core_views] = [Factory.create(:core_view_element)]
    @f.expects(:submit).with(I18n.t(:create), :id => 'create_core_view_submit')
    render "core_view_elements/_form.html.haml", :locals => {:f => @f}
  end

  it "renders if no available core views" do
    assigns[:available_core_views] = []
    render "core_view_elements/_form.html.haml", :locals => {:f => @f}
  end

end
