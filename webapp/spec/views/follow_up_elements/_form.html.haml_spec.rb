# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

describe "/follow_up_elements/_form.html.haml" do

  before do
    @fu = Factory.build(:follow_up_element)
    @fu.save_and_add_to_form
    assigns[:follow_up_element] = @fu

    @f = mock
    @f.expects(:hidden_field).with(:parent_element_id)
    @f.expects(:hidden_field).with(:core_data)
    @f.expects(:hidden_field).with(:event_type)
    @f.expects(:label).with(:condition)
  end

  it "renders if not core data" do
    @f.expects(:text_field).with(:condition)
    render "follow_up_elements/_form.html.haml", :locals => {:f => @f}
  end

  it "renders if core data is true" do
    @fu.stubs(:core_data).returns("true")
    @f.expects(:select).with(:core_path, [], {:include_blank => true})
    @f.expects(:label).with(:core_path)
    render "follow_up_elements/_form.html.haml", :locals => {:f => @f}
  end
end
