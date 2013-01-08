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

describe "searching with sensitive diseases" do

  before :all do
    destroy_fixture_data
  end

  after :all do
    Fixtures.reset_cache
  end

  describe "excluding sensitive diseases based on role" do

    before(:each) do
      create_starter_sensitive_disease_test_scenario
    end

    context "for the sensitive disease user" do
      it "should include all events except for the sensitive event in David County for a Bear Cub River user with sensitive disease privileges" do
        User.current_user = @sensitive_disease_user
        events = HumanEvent.find_by_name_and_bdate(:last_name => 'James')

        # The events that should be returned
        events.detect { |event| event.id == @sensitive_event.id }.should_not be_nil
        events.detect { |event| event.id == @sensitive_event_secondary.id }.should_not be_nil
        events.detect { |event| event.id == @not_sensitive_event.id }.should_not be_nil
        events.detect { |event| event.id == @event_without_a_disease.id }.should_not be_nil

        # The events that shouldn't be returned
        events.detect { |event| event.id == @sensitive_event_out_of_jurisdiction.id }.should be_nil
      end
    end

    context "for the not sensitive disease user" do
      before :each do
        User.current_user = @not_sensitive_disease_user
      end

      it "should not include any of the sensitive disease events" do
        events = HumanEvent.find_by_name_and_bdate(:last_name => 'James')

        # The events that should be returned
        events.detect { |event| event.id == @not_sensitive_event.id }.should_not be_nil
        events.detect { |event| event.id == @event_without_a_disease.id }.should_not be_nil

        # The events that shouldn't be returned
        events.detect { |event| event.id == @sensitive_event.id }.should be_nil
        events.detect { |event| event.id == @sensitive_event_secondary.id }.should be_nil
        events.detect { |event| event.id == @sensitive_event_out_of_jurisdiction.id }.should be_nil
      end

      it "shows blank rows when a patient has only sensitive-disease events" do
        create_morbidity_event(
          :patient => 'Simon',
          :disease => @sensitive_disease,
          :jurisdiction => @bear_cub_river
        )

        events = HumanEvent.find_by_name_and_bdate(:last_name => 'Simon')
        events.count.should == 1
        events.first['event_id'].should == nil
      end
    end
  end

end


