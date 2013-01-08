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

describe Lab do
  it "should not allow a lab (participation) to be built w/ a deleted place entity" do
    event = Factory(:morbidity_event)
    deleted_place_entity = Factory(:place_entity, :deleted_at => DateTime.now)
    participation = Lab.new(:event => event,
                            :primary_entity => event.interested_party.person_entity,
                            :secondary_entity => deleted_place_entity)
    participation.should_not be_valid
    participation.errors.size.should == 1
    participation.errors.full_messages.first.should =~ /#{deleted_place_entity.place.name.humanize} has been merged/i
  end

end
