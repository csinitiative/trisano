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

require File.dirname(__FILE__) + '/../spec_helper'
require RAILS_ROOT + '/app/helpers/application_helper'
include ApplicationHelper

describe PeopleManagementHelper do

  before do
    @event = searchable_event!(:morbidity_event, 'Jones')
    @person_entity = @event.interested_party.person_entity
    login_as_super_user
  end

  it "renders person actions as links" do
    actions = parse_html(helper.render_person_actions(@person_entity.person))
    actions.css('a').inner_text.should =~ /Show/
    actions.css('a').inner_text.should =~ /Edit/
    actions.css('a').inner_text.should =~ /Create and edit CMR using this person/
  end
end
