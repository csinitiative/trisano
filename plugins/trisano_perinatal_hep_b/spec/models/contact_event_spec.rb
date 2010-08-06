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

describe ContactEvent, "in the Perinatal Hep B plugin" do
  include PerinatalHepBSpecHelper
  include DiseaseSpecHelper
  include EventsSpecHelper
  include CodeSpecHelper

  before(:all) do
    given_a_disease_named('Hepatitis B Pregnancy Event')
    given_hep_b_external_codes_loaded
    given_p_hep_b_disease_specific_callbacks_loaded
    given_p_hep_b_treatments_loaded
  end

  
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

      it "should generate a task with the correct due date" do
        change_treatment_to_trigger_callback(@treatment)
        @contact_event.save!
        @contact_event.tasks.first.due_date.should == @due_date
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
        change_treatment_to_trigger_callback(@treatment)
        @contact_event.save!
        @contact_event.tasks.first.due_date.should == @due_date
        change_treatment_to_trigger_callback(@treatment, Date.yesterday)
        @contact_event.save!
        @contact_event.tasks.first.due_date.should == @due_date - 1.day
      end
      
    end

    describe "for Hepatitis B Dose 3 treatments" do

      before(:each) do
        @treatment = @dose_three_treatment
        @task_name = "Post serological testing due for Hepatitis B infant contact."
        @due_date = Date.today + 1.month
        @task_tracking_key = 'hep_b_dose_three'
      end

      it_should_behave_like "task-worthy treatments"

    end

    describe "for Hepatitis B – Comvax Dose 4 treatments" do

      before(:each) do
        @treatment = @comvax_dose_four_treatment
        @task_name = "Post serological testing due for Hepatitis B infant contact."
        @due_date = Date.today + 1.month
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

      it "should not generate a task when the contact type isn't a match" do
        @contact_event.update_attributes!(:participations_contact => Factory.create(:participations_contact))
        change_treatment_to_trigger_callback(@treatment)
        lambda { @contact_event.save! }.should change(Task, :count).by(0)
      end
    end

  end
end
