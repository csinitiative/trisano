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

require File.expand_path(File.dirname(__FILE__) +  '/../../../../../spec/spec_helper')

describe MorbidityEvent, "in the Perinatal Hep B plugin" do
  include DiseaseSpecHelper
  include PerinatalHepBSpecHelper

  describe "updating expected delivery date" do
    before do
      @disease = disease!('Hepatitis B Pregnancy Event')
      given_hep_b_callbacks_loaded
      @event = human_event_with_demographic_info!(:morbidity_event)
      @event.build_disease_event(:disease => @disease)
      @event.update_attributes!(:state_manager => create_user_in_role!('State Manager', 'Joey Bagadonuts'))
      @event.interested_party.build_risk_factor(:pregnancy_due_date => Date.today + 2)
    end

    it "onlys generate task if disease is appropriate (ie, Hep B Pregnancy Event)" do
      @event.build_disease_event(:disease => disease!('The Trots'))
      lambda { @event.save! }.should_not change(Task, :count)
    end

    it "should generate one task if expected delivery date entered" do
      lambda { @event.save! }.should change(Task, :count).by(1)
    end

    it "should not generate more then one task per event for expected delivery date" do
      @event.save!
      lambda { @event.save! }.should_not change(Task, :count)
    end

    it "should generate the task for the state manager" do
      @event.save!
      @event.tasks.any? { |task| task.user == @event.state_manager }.should be_true
    end

    it "should generate the task with the due date set to the expected delivery date" do
      @event.save!
      @event.tasks.any? { |task| task.due_date == @event.interested_party.risk_factor.pregnancy_due_date }.should be_true
    end

    it "should generate the task with the name 'Hepatitis B Pregnancy Event: expected delivery date entered'" do
      @event.save!
      @event.tasks.any? { |task| task.name == "Hepatitis B Pregnancy Event: expected delivery date entered" }.should be_true
    end

    it "does not generate a task if there is no state manager" do
      @event.update_attributes!(:state_manager => nil)
      lambda { @event.save! }.should_not change(Task, :count)
    end

    it "deletes the existing task creates a new one when the delivery date is changed" do
      @event.save!
      lambda do
        @event.interested_party.risk_factor.pregnancy_due_date = Date.today + 3
        @event.save!
      end.should_not change(Task, :count)
      @event.tasks.any? { |task| task.due_date = Date.today + 3 }.should be_true
    end

    it "deletes the existing task when the expected delivery date is removed" do
      @event.save!
      lambda do
        @event.interested_party.risk_factor.pregnancy_due_date = nil
        @event.save!
      end.should change(Task, :count).by(-1)
    end
  end
end
