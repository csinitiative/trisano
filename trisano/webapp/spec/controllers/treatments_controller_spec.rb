# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

describe TreatmentsController do
  describe "handling GET /treatments" do

    before(:each) do
      set_up_local_mocks
      @participations_treatments.stub!(:find).and_return([@participations_treatment])
    end
  
    def do_get
      get :index, :cmr_id => "1"
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
  
    it "should find all treatments" do
      @participations_treatments.should_receive(:find).with(:all).and_return([@participations_treatment])
      do_get
    end
  
    it "should assign the found treatments for the view" do
      do_get
      assigns[:participations_treatments].should == [@participations_treatment]
    end
  end

  describe "handling GET /treatments/1" do

    before(:each) do
      set_up_local_mocks
      @participations_treatments.stub!(:find).and_return(@participations_treatment)
    end
  
    def do_get
      get :show, :cmr_id => "1", :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  
    it "should find the treatment requested" do
      @participations_treatments.should_receive(:find).with("1").and_return(@participations_treatment)
      do_get
    end
  
    it "should assign the found treatment for the view" do
      do_get
      assigns[:participations_treatment].should equal(@participations_treatment)
    end
  end

  describe "handling GET /treatments/new" do

    before(:each) do
      set_up_local_mocks
      ParticipationsTreatment.stub!(:new).and_return(@participations_treatment)
    end
  
    def do_get
      get :new, :cmr_id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render new template" do
      do_get
      response.should render_template('new')
    end
  
    it "should create an new treatment" do
      ParticipationsTreatment.should_receive(:new).and_return(@participations_treatment)
      do_get
    end
  
    it "should not save the new treatment" do
      @participations_treatment.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new treatment for the view" do
      do_get
      assigns[:participations_treatment].should equal(@participations_treatment)
    end
  end

  describe "handling GET /treatments/1/edit" do

    before(:each) do
      set_up_local_mocks
      @participations_treatments.stub!(:find).and_return(@participations_treatment)
    end
  
    def do_get
      get :edit, :id => "1", :cmr_id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the treatment requested" do
      @participations_treatments.should_receive(:find).and_return(@participations_treatment)
      do_get
    end
  
    it "should assign the found Treatment for the view" do
      do_get
      assigns[:participations_treatment].should equal(@participations_treatment)
    end
  end

  describe "handling POST /treatments" do

    before(:each) do
      set_up_local_mocks
      ParticipationsTreatment.stub!(:new).and_return(@participations_treatment)
    end
    
    describe "with successful save" do
  
      def do_post
        @participations_treatments.should_receive(:<<).and_return(true)
        post :create, :participations_treatment => {}, :cmr_id => "1"
      end
  
      it "should create a new treatment" do
        ParticipationsTreatment.should_receive(:new).and_return(@participations_treatment)
        do_post
      end

      it "should update display" do
        do_post
        response.should have_rjs(:replace_html, "treatment-list")
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @participations_treatments.should_receive(:<<).and_return(false)
        post :create, :participations_treatment => {}, :cmr_id => "1"
      end
  
      it "should trigger a javascript alert" do
        do_post
        response.should have_text(/alert/) 
        response.should have_text(/Validation failed/) 
      end
      
    end
  end

  describe "handling PUT /treatments/1" do

    before(:each) do
      set_up_local_mocks
      @participations_treatments.stub!(:find).and_return(@participations_treatment)
    end
    
    describe "with successful update" do

      def do_put
        @participations_treatment.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1", :cmr_id => "1"
      end

      it "should find the treatment requested" do
        @participations_treatments.should_receive(:find).with("1").and_return(@participations_treatment)
        do_put
      end

      it "should update the found treatment" do
        do_put
        assigns(:participations_treatment).should equal(@participations_treatment)
      end

      it "should assign the found treatment for the view" do
        do_put
        assigns(:participations_treatment).should equal(@participations_treatment)
      end

      it "should update the treatment list" do
        do_put
        response.should have_rjs(:replace_html, "treatment-list")
      end

    end
    
    describe "with failed update" do

      def do_put
        @participations_treatment.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1", :cmr_id => "1"
      end

      it "should send a javascript alert" do
        do_put
        response.should have_text(/alert/) 
        response.should have_text(/Validation failed/) 
      end

    end
  end

  describe "handling DELETE /treatments/1" do

    before(:each) do
      set_up_local_mocks
    end
  
    def do_delete
      delete :destroy, :id => "1", :cmr_id => "1"
    end

    it "should always return HTTP Response Code: Method not allowed" do
      do_delete
      response.headers["Status"].should == "405 Method Not Allowed"
    end
  end

  def set_up_local_mocks
    mock_user
    @cmr = mock_model(Event, :to_param => "1")
    @active_patient = mock_model(Participation, :to_param => "1")
    @participations_treatment = mock_model(ParticipationsTreatment, :to_param => "1", :errors => stub("errors", :count => 0, :null_object => true))
    @participations_treatments = mock(Array, :null_object => :true)

    Event.stub!(:find).with("1").and_return(@cmr)
    @cmr.stub!(:active_patient).and_return(@active_patient)
    @active_patient.stub!(:participations_treatments).and_return(@participations_treatments)
  end
end
