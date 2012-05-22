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

describe AssessmentEvent do
  before :all do
    destroy_fixture_data
  end

  after :all do
    Fixtures.reset_cache
  end

  before(:each) do
    @event = Factory.build(:assessment_event)
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

  it "is invalid if disease onset date is after first reported to public health date" do
    @event.disease_event = Factory.build(:disease_event, :disease_onset_date => Date.today)
    @event.save.should be_false
    @event.should have(1).error_on('disease_event.disease_onset_date')
    @event.disease_event.errors[:disease_onset_date]
  end

  it "is valid if disease onset date is on first reported to public health date" do
    @event.disease_event = Factory.build(:disease_event, :disease_onset_date => Date.yesterday)
    @event.save.should be_true
  end

  it "is valid if disease onset date is before first reported to public health date" do
    @event.disease_event = Factory.build(:disease_event, :disease_onset_date => Date.today - 2.days)
    @event.save.should be_true
  end

  describe "#before_create" do
    before do
      given_an_unassigned_jurisdiction
    end

    it "sets the workflow state to 'new' if the event is Unassigned" do
      @event.jurisdiction.place_entity = nil
      @event.save.should be_true
      @event.workflow_state.should == 'new'
    end

    it "sets the workflow state to 'accepted_by_lhd' if the event is assigned to a jurisdiction" do
      @event.save.should be_true
      @event.workflow_state.should == 'accepted_by_lhd'
    end

  end

end
