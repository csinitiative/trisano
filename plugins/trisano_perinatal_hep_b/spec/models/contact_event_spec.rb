# -*- coding: utf-8 -*-
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

describe ContactEvent, "in the Perinatal Hep B plugin" do

  before(:all) do
    destroy_fixture_data
    given_a_disease_named('Hepatitis B Pregnancy Event')
    given_hep_b_external_codes_loaded
    given_p_hep_b_disease_specific_callbacks_loaded
    given_p_hep_b_treatments_loaded
  end

  after(:all) { Fixtures.reset_cache }


  describe "generating tasks for an investigator" do
    def change_treatment_to_trigger_callback(treatment, date=Date.today)
      @contact_event.interested_party.treatments[0].treatment = treatment
      @contact_event.interested_party.treatments[0].treatment_date = date
    end

    before(:each) do
      given_task_category_codes_loaded
      @disease = Disease.find_by_disease_name('Hepatitis B Pregnancy Event')
      @morbidity_event = given_a_morb_with_disease(@disease)

      @morbidity_event = Factory.create(:morbidity_event,
        :disease_event => Factory.create(:disease_event, :disease => @disease),
        :investigator => Factory.create(:user)
      )

      @actual_delivery_facility = add_actual_delivery_facility_to_event(@morbidity_event, "Allen Hospital")

      @infant_contact_type_code = ExternalCode.infant_contact_type

      @participations_contact = Factory.create(
        :participations_contact,
        :contact_type => @infant_contact_type_code
      )

      @contact_event = Factory.create(:contact_event,
        :participations_contact => @participations_contact,
        :parent_event => @morbidity_event,
        :disease_event => Factory.create(:disease_event, :disease => @disease)
      )
      @contact_event.interested_party.treatments.create!(:treatment_id => Factory.create(:treatment).id)

      @dsc = Factory.create(:disease_specific_callback,
        :callback_key => "treatment_date_required",
        :disease => @disease
      )

      @dose_one_treatment = Treatment.find_by_treatment_name("Hepatitis B Dose 1")
      raise "Hepatitis B Dose 1 treatment should be found" unless @dose_one_treatment

      @dose_three_treatment = Treatment.find_by_treatment_name("Hepatitis B Dose 3")
      raise "Hepatitis B Dose 3 treatment should be found" unless @dose_three_treatment

      @comvax_dose_four_treatment = Treatment.find_by_treatment_name("Hepatitis B - Comvax Dose 4")
      raise "Hepatitis B – Comvax Dose 4 treatment should be found" unless @comvax_dose_four_treatment
    end

    shared_examples_for "task-worthy treatments" do

      it "should generate a task when one doesn't already exist" do
        change_treatment_to_trigger_callback(@treatment)
        lambda { @contact_event.save! }.should change(Task, :count).by(1)
      end

      it "should generate a task with the correct name" do
        change_treatment_to_trigger_callback(@treatment)
        @contact_event.save!
        @contact_event.tasks.first.name.should == @task_name
      end

      it "should generate a task with the correct name" do
        change_treatment_to_trigger_callback(@treatment)
        @contact_event.save!
        @contact_event.tasks.first.name.should == @task_name
      end

      it "when there is no contact dob, should generate a task with the correct due date 30 days after the treatment, as long as it is still 9 months after the parent's actual delivery date" do
        @actual_delivery_facility.actual_delivery_facilities_participation.actual_delivery_date = 9.months.ago.to_date
        @contact_event.interested_party.person_entity.person.birth_date = nil
        @contact_event.save!
        treatment_date = Date.today
        change_treatment_to_trigger_callback(@treatment, treatment_date)
        @contact_event.save!
        @contact_event.tasks.first.due_date.should == treatment_date + 30.days
      end

      it "when there is no contact dob, should generate a task with a due date at least 9 months after the parent's actual delivery date" do
        @actual_delivery_facility.actual_delivery_facilities_participation.actual_delivery_date = Date.yesterday
        @contact_event.interested_party.person_entity.person.birth_date = nil
        @contact_event.save!
        treatment_date = Date.today
        change_treatment_to_trigger_callback(@treatment, treatment_date)
        @contact_event.save!
        @contact_event.tasks.first.due_date.should == Date.yesterday + 9.months
      end

      it "when there is no contact dob and no actual delivery date for the parent, should generate a task with a due date 90 days after the treatment date" do
        @morbidity_event.actual_delivery_facility = nil
        @morbidity_event.save!
        @contact_event.interested_party.person_entity.person.birth_date = nil
        @contact_event.save!
        treatment_date = Date.today
        change_treatment_to_trigger_callback(@treatment, treatment_date)
        @contact_event.save!
        @contact_event.tasks.first.due_date.should == treatment_date + 90.days
      end

      it "should generate a task with a due date at least 9 months after the birth date" do
        @contact_event.interested_party.person_entity.person.birth_date = Date.yesterday
        @contact_event.save!
        treatment_date = Date.today
        change_treatment_to_trigger_callback(@treatment, treatment_date)
        @contact_event.save!
        @contact_event.tasks.first.due_date.should == Date.yesterday + 9.months
      end

      it "should generate a task with the correct due date 30 days after the treatment, as long as it is still 9 months after the birth date" do
        @contact_event.interested_party.person_entity.person.birth_date = 9.months.ago.to_date
        @contact_event.save!
        treatment_date = Date.today
        change_treatment_to_trigger_callback(@treatment, treatment_date)
        @contact_event.save!
        @contact_event.tasks.first.due_date.should == treatment_date + 30.days
      end

      it "should generate a task with the status pending" do
        change_treatment_to_trigger_callback(@treatment)
        @contact_event.save!
        @contact_event.tasks.first.status.should == 'pending'
      end

      it "should generate a task with the category Treatment" do
        change_treatment_to_trigger_callback(@treatment)
        @contact_event.save!
        @contact_event.tasks.first.category_id.should == ExternalCode.find_by_code_name_and_the_code('task_category', 'TM').id
      end

      it "should generate a task with the correct task tracking key" do
        change_treatment_to_trigger_callback(@treatment)
        @contact_event.save!
        @contact_event.tasks.first.task_tracking_key.should == @task_tracking_key
      end

      it "should not generate a new task if one already exists for this treatment" do
        change_treatment_to_trigger_callback(@treatment)
        lambda { @contact_event.save! }.should change(Task, :count).by(1)
        change_treatment_to_trigger_callback(@treatment, Date.yesterday)
        lambda { @contact_event.save! }.should change(Task, :count).by(0)
      end

      it "should update the existing task's due date if the treatment date has changed and the task already exists" do
        @contact_event.interested_party.person_entity.person.birth_date = 9.months.ago.to_date
        change_treatment_to_trigger_callback(@treatment, Date.today)
        @contact_event.save!
        @contact_event.tasks.first.due_date.should == Date.today + 30.days
        change_treatment_to_trigger_callback(@treatment, Date.yesterday)
        @contact_event.save!
        @contact_event.tasks.first.due_date.should == Date.yesterday + 30.days
      end

      it "should not change the existing task's due date if the treatment date has changed and the task already exists, but the contact's birth date was less than 9 months ago" do
        birth_date = 2.days.ago.to_date
        @contact_event.interested_party.person_entity.person.birth_date = birth_date
        @contact_event.save!
        change_treatment_to_trigger_callback(@treatment, Date.today)
        @contact_event.save!
        @contact_event.tasks.first.due_date.should == birth_date + 9.months
        change_treatment_to_trigger_callback(@treatment, Date.yesterday)
        @contact_event.save!
        @contact_event.tasks.first.due_date.should == birth_date + 9.months
      end

      it "should change the existing task's due date if the treatment date has changed and the task already exists, and the treatment date was changed so that the due date is outside of the birth date window" do
        birth_date = 10.months.ago.to_date
        @contact_event.interested_party.person_entity.person.birth_date = birth_date
        @contact_event.save!
        treatment_date_inside_birth_date_window = 7.months.ago.to_date
        change_treatment_to_trigger_callback(@treatment, treatment_date_inside_birth_date_window)
        @contact_event.save!
        @contact_event.tasks.first.due_date.should == birth_date + 9.months
        
        treatment_date_outside_birth_date_window = 1.month.ago.to_date - 15.days
        change_treatment_to_trigger_callback(@treatment, treatment_date_outside_birth_date_window)
        @contact_event.save!
        @contact_event.tasks.first.due_date.should == treatment_date_outside_birth_date_window + 30.days
      end

    end

    describe "for Hepatitis B Dose 3 treatments" do

      before(:each) do
        @treatment = @dose_three_treatment
        @task_name = "Post serological testing due."
        @task_tracking_key = 'hep_b_dose_three'
      end

      it_should_behave_like "task-worthy treatments"

    end

    describe "for Hepatitis B – Comvax Dose 4 treatments" do

      before(:each) do
        @treatment = @comvax_dose_four_treatment
        @task_name = "Post serological testing due."
        @task_tracking_key = 'hep_b_comvax_dose_four'
      end

      it_should_behave_like "task-worthy treatments"
    end

    describe "for not-task-worthy treatments" do
      before(:each) do
        @treatment = @dose_one_treatment
      end

      it "should not generate a task" do
        change_treatment_to_trigger_callback(@treatment)
        lambda { @contact_event.save! }.should change(Task, :count).by(0)
      end
    end

    describe "for not-worthy events" do
      before(:each) do
        @treatment = @dose_three_treatment
      end

      it "should not generate a task when there is no investigator on the event" do
        @morbidity_event.update_attributes!(:investigator => nil)
        change_treatment_to_trigger_callback(@treatment)
        lambda { @contact_event.save! }.should change(Task, :count).by(0)
      end

      it "should not generate a task when the disease is nil" do
        @contact_event.disease.update_attributes!(:disease => nil)
        change_treatment_to_trigger_callback(@treatment)
        lambda { @contact_event.save! }.should change(Task, :count).by(0)
      end

      it "should not generate a task when the disease is not a match" do
        @contact_event.update_attributes!(:disease_event => Factory.create(:disease_event))
        change_treatment_to_trigger_callback(@treatment)
        lambda { @contact_event.save! }.should change(Task, :count).by(0)
      end

      it "should generate a task regardless of contact type" do
        @contact_event.update_attributes!(:participations_contact => Factory.create(:participations_contact))
        change_treatment_to_trigger_callback(@treatment)
        lambda { @contact_event.save! }.should change(Task, :count).by(1)
      end
    end

  end
end
