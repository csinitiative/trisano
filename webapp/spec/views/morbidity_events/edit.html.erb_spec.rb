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

require 'spec_helper'

describe "/cmrs/:id/edit" do

  before :all do
    given_core_fields_loaded_for :morbidity_event
  end

  it "renders a cmr in edit mode" do
    assigns[:event] = Factory.create(:morbidity_event)
    login_as_super_user
    User.stubs(:current_user).returns(@current_user)
    render "/morbidity_events/edit.html.erb"
  end

  describe "rendering a cmr elevated from a contact event" do
    before do
      @parent = Factory.create(:morbidity_event)
      @promote_contact = Factory.create(:contact_event, :parent_event => @parent)
      @contact = Factory.create(:contact_event, :parent_event => @parent)

      #pffft
      login_as_super_user
      User.stubs(:current_user).returns(@current_user)

      @cmr = @contact.promote_to_morbidity_event
      assigns[:event] = @cmr
      render "/morbidity_events/edit.html.erb"
    end

    it "displays a link to the parent event" do
      response.should have_tag('a[href=?]', edit_cmr_path(@parent))
    end
  end

  it "should render an event w/ associated jurisdictions" do
    user = Factory.create :user
    assigns[:event] = Factory.create :morbidity_event
    assigns[:event].associated_jurisdictions.create(:secondary_entity_id => create_jurisdiction_entity.id)
    render "/morbidity_events/edit.html.erb"
  end
end
