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

require 'spec_helper'

describe MorbidityEvent, "in the Perinatal Hep B plugin" do
  include DiseaseSpecHelper
  include PerinatalHepBSpecHelper

  before do
    @disease = disease!('Hepatitis B Pregnancy Event')
    given_p_hep_b_disease_specific_callbacks_loaded
    @event = human_event_with_demographic_info!(:morbidity_event)
    @event.build_disease_event(:disease => @disease)
    @state_manager = create_user_in_role!('State Manager', 'Joey Bagadonuts')
    @event.update_attributes! :state_manager => @state_manager
  end

  describe "generating a task for expected delivery date" do
    before do
      @event.interested_party.build_risk_factor(:pregnancy_due_date => Date.today + 2)
    end

    it "only generate a task if disease is Hepatitis B Pregnancy Event" do
      @event.build_disease_event(:disease => disease!('The Trots'))
      lambda { @event.save! }.should_not change(Task, :count)
    end

    it "generate one task if expected delivery date entered" do
      lambda { @event.save! }.should change(Task, :count).by(1)
    end

    it "do not generate a task if expected delivery date hasn't changed" do
      @event.save!
      lambda { @event.save! }.should_not change(Task, :count)
    end

    it "generates the task for the state manager" do
      @event.save!
      @event.tasks.any? { |task| task.user == @event.state_manager }.should be_true
    end

    it "does not generate a task if there is no state manager" do
      @event.update_attributes!(:state_manager => nil)
      lambda { @event.save! }.should_not change(Task, :count)
    end

    it "generates a task if the state manager is entered later" do
      @event.update_attributes! :state_manager => nil
      @event.save!
      @event.state_manager = @state_manager
      lambda { @event.save! }.should change(Task, :count).by(1)
    end

    it "should generate the task with the due date set to today" do
      @event.save!
      @event.tasks.any? { |task| task.due_date == Date.today }.should be_true
    end

    it "generates the task with the name 'Hepatitis B Pregnancy Event: expected delivery date entered'" do
      @event.save!
      @event.tasks.any? { |task| task.name == "Hepatitis B Pregnancy Event: expected delivery date entered" }.should be_true
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

  describe "generating a task for expected delivery facility" do
    before do
      @event.interested_party.build_risk_factor(:pregnancy_due_date => Date.today + 2)
      @event.build_expected_delivery_facility(:place_entity => Factory.create(:place_entity))
    end

    it "only generates a task if disease is Hepatitis B Pregnancy Event" do
      @event.build_disease_event(:disease => disease!('The Trots'))
      lambda { @event.save! }.should_not change(Task, :count)
    end

    it "if the due date *and* the expected delivery facility are entered, generate an additional task for the delivery facility" do
      lambda { @event.save! }.should change(Task, :count).by(2)
    end

    it "generates tasks if the state manager is entered later" do
      @event.update_attributes! :state_manager => nil
      @event.save!
      @event.state_manager = @state_manager
      lambda { @event.save! }.should change(Task, :count).by(2)
    end

    it "generates tasks with due date set to today" do
      @event.save!
      @event.tasks.all? { |task| task.due_date == Date.today }.should be_true
    end

    it "generates the delivery facility task when the facility is entered, if the due date already exists" do
      @event.expected_delivery_facility = nil
      @event.save!
      @event.build_expected_delivery_facility(:place_entity => Factory.create(:place_entity))
      lambda { @event.save! }.should change(Task, :count).by(1)
    end

    it "generates the both tasks when the due date is entered, if the expected delivery facility already exists" do
      @event.interested_party.risk_factor.pregnancy_due_date = nil
      lambda { @event.save! }.should_not change(Task, :count)
      @event.interested_party.build_risk_factor(:pregnancy_due_date => Date.today + 2)
      lambda { @event.save! }.should change(Task, :count).by(2)
    end

    it "generates the task with the name 'Hepatitis B Pregnancy Event: expected delivery date and hospital entered'" do
      @event.save!
      @event.tasks.any? do |task|
        task.name == 'Hepatitis B Pregnancy Event: expected delivery date and hospital entered'
      end.should be_true
    end

  end
end
