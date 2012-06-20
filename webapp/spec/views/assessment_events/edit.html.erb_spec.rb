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

require 'spec_helper'

describe "/aes/:id/edit" do

  before :all do
    given_core_fields_loaded_for :assessment_event
  end

  it "renders a AE in edit mode" do
    assigns[:event] = Factory.create(:assessment_event)
    login_as_super_user
    User.stubs(:current_user).returns(@current_user)
    render "/assessment_events/edit.html.erb"
  end

  describe "rendering a AE elevated from a contact event"

  it "should render an event w/ associated jurisdictions" do
    user = Factory.create :user
    assigns[:event] = Factory.create :assessment_event
    assigns[:event].associated_jurisdictions.create(:secondary_entity_id => create_jurisdiction_entity.id)
    render "/assessment_events/edit.html.erb"
  end
end
