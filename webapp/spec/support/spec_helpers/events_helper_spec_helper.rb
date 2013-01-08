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
require RAILS_ROOT + '/spec/support/spec_helpers/html_spec_helper'

module EventsHelperSpecHelper

  def assert_event_links(type, show_link, edit_link)
    event = Factory.create(type)
    login_as_super_user
    out = helper.show_and_edit_event_links(event)
    links = Nokogiri::HTML.parse(out)
    clean_nbsp(links.css("#show-event-#{event.id}").text).should == show_link
    clean_nbsp(links.css("#edit-event-#{event.id}").text).should == edit_link
  end
end
