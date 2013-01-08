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

Then /^I should see a link to promote event to a CMR from an assessment$/ do
  response.should have_selector("a#event-type[href='#{event_type_ae_path(@event)}?type=morbidity_event']")
end

When /^I promote the assessment to a morbidity event$/ do
  visit ae_path(@event)
  click_link "Promote to CMR"

  # we want to make available the promoted event at a later time
  # but only if the promotion was successful
  if current_url == cmr_url(@event)
    #Then reload the event to make it available for other steps
    @promoted_event = MorbidityEvent.find(@event.id)
  end
end

Then /^I should be viewing the show morbidity event for the assessment page$/ do
  path = cmr_path(@event)
  current_url.should =~ /#{path}/
end
