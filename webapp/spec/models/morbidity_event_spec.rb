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

require File.dirname(__FILE__) + '/../spec_helper'

describe MorbidityEvent do

  before(:each) do
    @event = Factory.build(:morbidity_event)
  end

  it "should be valid" do
    @event.should be_valid
  end

  it "should be invalid without a patient last name" do
    @event.interested_party.person_entity.person.last_name = ""
    @event.save.should be_false
    @event.should have(1).error_on("interested_party.person_entity.person.last_name")
  end

  it "should be invalid without a first reported to public health date" do
    @event.first_reported_PH_date = ""
    @event.save.should be_false
    @event.should have(1).error_on("first_reported_PH_date")
    @event.error_on("first_reported_PH_date").include?("can't be blank").should be_true
  end

  it "should be invalid with a first reported to public health date after the created_at date" do
    @event.first_reported_PH_date = Date.tomorrow
    @event.save.should be_false
    @event.should have(1).error_on("first_reported_PH_date")
    @event.error_on("first_reported_PH_date").include?("must be on or before #{Date.today}").should be_true
  end

  it "should be valid with a first reported to public health date before the created_at date" do
    @event.first_reported_PH_date = Date.yesterday
    @event.save.should be_true
    @event.should have(0).errors_on("first_reported_PH_date")
  end

end
