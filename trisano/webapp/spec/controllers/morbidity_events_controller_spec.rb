
# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

# Many specs are commented out. The mocking exercise is not a small undertaking.
# Perhaps it can be chipped away at.

describe MorbidityEventsController do
  describe "handling GET /events" do

    before(:each) do
      mock_user
      @event = mock_event
      Event.stub!(:find).and_return([@event])
      @user.stub!(:jurisdiction_ids_for_privilege).with(:view_event).and_return([75])
      @event.stub!(:read_attribute).and_return('MorbidityEvent') 
    end
  
    def do_get
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
  
    it "should find all events" do
      MorbidityEvent.should_receive(:find_all_for_filtered_view).with(kind_of(Hash)).and_return([@event])
      do_get
    end
  
    it "should assign the found events for the view" do
      do_get
      assigns[:events].should == [@event]
    end
  end

  describe "handling GET /events/1 with view entitlement" do

    before(:each) do
      mock_user
      @event = mock_event
      Event.stub!(:find).and_return(@event)
      @user.stub!(:is_entitled_to_in?).with(:view_event, 75).and_return(true)
      @event.stub!(:read_attribute).and_return('MorbidityEvent') 
    end
  
    def do_get
      get :show, :id => "75"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  
    it "should find the event requested" do
      Event.should_receive(:find).once().with("75").and_return(@event)
      do_get
    end
  
    it "should assign the found event for the view" do
      do_get
      assigns[:event].should equal(@event)
    end
  end

  describe "handling GETting a real event of the wrong type" do

    before(:each) do
      mock_user
      @event = mock_event
      Event.stub!(:find).and_return(@event)
      @user.stub!(:is_entitled_to_in?).with(:view_event, 75).and_return(true)
      @event.stub!(:read_attribute).and_return('ContactEvent') 
    end
  
    def do_get
      get :show, :id => "75"
    end

    it "should find the event requested" do
      Event.should_receive(:find).with("75").and_return(@event)
      do_get
    end

    it "should return a 404" do
      do_get
      response.response_code.should == 404
    end

    it "should render the public 404 page" do
      do_get
      response.should render_template("#{RAILS_ROOT}/public/404.html")
    end

  end
  
  describe "handling GET /events/1 without view entitlement" do

    before(:each) do
      mock_user
      @event = mock_event
      @event.stub!(:add_note)
      Event.stub!(:find).and_return(@event)
      @user.stub!(:is_entitled_to_in?).and_return(false)
      @event.stub!(:read_attribute).and_return('MorbidityEvent') 
    end
  
    def do_get
      get :show, :id => "75"
    end

    it "should find the event requested" do
      Event.should_receive(:find).with("75").and_return(@event)
      do_get
    end
  
    it "should log access and be successful" do
      @event.should_receive(:add_note)
      do_get
      response.should be_success
    end
  
  end
  
  describe "handling GET /events/new" do
  
    before(:each) do
      mock_user
      @event = mock_event
      MorbidityEvent.stub!(:new).and_return(@event)
      @user.stub!(:is_entitled_to?).with(:create_event).and_return(true)
      @event.stub!(:read_attribute).and_return('MorbidityEvent') 
    end
    
    def do_get
      get :new
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end
    
    it "should render new template" do
      do_get
      response.should render_template('new')
    end
    
    it "should create an new event" do
      MorbidityEvent.should_receive(:new).and_return(@event)
      do_get
    end
    
    it "should not save the new event" do
      @event.should_not_receive(:save)
      do_get
    end
    
    it "should assign the new event for the view" do
      do_get
      assigns[:event].should equal(@event)
    end
  end
  
  describe "handling GET /events/1/edit with update entitlement" do

    before(:each) do
      mock_user
      @event = mock_event
      @form_reference = mock_model(FormReference)
      @form = mock_model(Form, :null_object => true)

      Event.stub!(:find).and_return(@event)
      @event.stub!(:get_investigation_forms).and_return([@form])
      @user.stub!(:is_entitled_to_in?).with(:update_event, 75).and_return(true)
      @event.stub!(:read_attribute).and_return('MorbidityEvent') 
    end
  
    def do_get
      get :edit, :id => "75"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the event requested" do
      Event.should_receive(:find).and_return(@event)
      do_get
    end
  
    it "should assign the found MorbidityEvent for the view" do
      do_get
      assigns[:event].should equal(@event)
    end
  end

  describe "handling JURISDICTION requests /events/1/jurisdiction" do
    before(:each) do
      mock_user
      @user.stub!(:is_entitled_to_in?).with(:route_event_to_any_lhd, 1).and_return(true)
      @user.stub!(:is_entitled_to_in?).with(:create_event, "2").and_return(true)
      @user.stub!(:jurisdiction_ids_for_privilege).with(:view_event).and_return([1])

      @jurisdiction = mock_model(Participation)
      @jurisdiction.stub!(:secondary_entity_id).and_return(1)

      @primary_jurisdiction = mock_model(Place)
      @primary_jurisdiction.stub!(:name).and_return('Not Unassigned')

      @event = mock_model(MorbidityEvent, :to_param => "1")
      @event.stub!(:jurisdiction).and_return(@jurisdiction)
      @event.stub!(:update_attribute).and_return(true)
      @event.stub!(:primary_jurisdiction).and_return(@primary_jurisdiction)
      MorbidityEvent.stub!(:find).and_return(@event)
    end

    describe "with successful routing" do
      def do_route_event
        Event.should_receive(:find).and_return(@event)
        request.env['HTTP_REFERER'] = "/some_path"
        @event.should_receive(:assign_to_lhd)
        @event.should_receive(:save!)
        post :jurisdiction, :id => "1", :jurisdiction_id => "2"
      end
      
      it "should find the event requested" do
        do_route_event
      end
      
      it "should redirect to the where it was called from" do
        do_route_event
        response.should redirect_to("http://test.host/some_path")
      end

      describe "setting the status field" do
        describe "with a new route" do
          it "should change status to ASGD-LHD" do
            do_route_event
          end
        end

        describe "With an existing route" do
          it "should not change status" do
            @jurisdiction.stub!(:secondary_entity_id).and_return(2)
            @event.should_not_receive(:update_attribute)
            do_route_event
          end
        end
      end

      describe "with secondary_ids too" do
        it "should pass IDs into event#route_to_jurisdiction" do
          Event.should_receive(:find).and_return(@event)
          @event.should_receive(:assign_to_lhd)
          @event.should_receive(:save!)
          request.env['HTTP_REFERER'] = "/some_path"
          post :jurisdiction, :id => "1", :jurisdiction_id => "2", :secondary_jurisdiction_ids => ["3", "4"], :note => ""
        end
      end
    end

    describe "with failed routing" do
      def do_route_event
        Event.should_receive(:find).and_return(@event)
        request.env['HTTP_REFERER'] = "/some_path"
        @event.should_receive(:halted?).and_return false
        post :jurisdiction, :id => "1", :jurisdiction_id => "2"
      end

      it "should redirect to where the user came from" do
        do_route_event
        response.should redirect_to("http://test.host/some_path")
      end
    end
  end

  describe "handling STATE actions /events/1/state" do
    def set_up_mocks
      mock_user
      @user.stub!(:is_entitled_to_in?).with(:a_privilege, 1).and_return(true)
      @user.stub!(:jurisdiction_ids_for_privilege).with(:view_event).and_return([1])

      @jurisdiction = mock_model(Participation)
      @jurisdiction.stub!(:secondary_entity_id).and_return(1)

      @event = mock_model(MorbidityEvent, :to_param => "1")
      @event.stub!(:jurisdiction).and_return(@jurisdiction)
      @event.stub!(:update_attributes).and_return(true)
      @event.stub!(:attributes=).and_return(1)
      @event.stub!(:investigator_id=).and_return(@user.id)
      @event.stub!(:investigation_started_date=)
      @event.stub!(:add_note)
      MorbidityEvent.stub!(:find).and_return(@event)
      ExternalCode.stub!(:event_code_str).and_return("A_PRIV")
    end

    describe "with successful state change" do
      before(:each) do
        set_up_mocks
      end

      def do_change_state
        Event.should_receive(:find).with("1").and_return(@event)
        request.env['HTTP_REFERER'] = "/some_path"
        @event.should_receive(:a_status)
        @event.should_receive(:save).and_return(true)
        post :state, :id => "1", :morbidity_event => {:workflow_action=> 'a_status'}
      end

      it "should find the event requested" do
        do_change_state
      end
      
      it "should redirect to the where it was called from" do
        do_change_state
        response.should redirect_to("http://test.host/some_path")
      end
    end

    describe "with bad state argument" do
      
      def do_change_state
        mock_user
        event = mock_model(MorbidityEvent, :to_param => "1")        
        event.should_receive(:halted?).and_return true
        Event.should_receive(:find).with("1").and_return(event)

        request.env['HTTP_REFERER'] = "/some_path"
        post :state, :id => "1", :morbidity_event => {:workflow_action => 'a_status'}
      end

      it "should respond with a 403" do
        do_change_state
        response.code.should == "403"        
      end
    end

    describe "with insufficent privileges" do
      def do_change_state
        mock_user
        event = mock_model(MorbidityEvent, :to_param => "1")
        event.should_receive(:halted?).and_return true
        Event.should_receive(:find).and_return(event)

        post :state, :id => "1", :morbidity_event => {:event_status => 'a_status'}
      end

      it "should respond with a 403" do
        do_change_state
        response.code.should == "403"
      end
    end

    describe "with a failed state change" do
      def do_change_state
        mock_user
        @event = mock_event        
                
        User.stub!(:current_user).and_return(@user)
        @event.should_receive(:a_status)
        @event.should_receive(:save).and_return(false)
        @event.should_receive(:attributes=)
        Event.should_receive(:find).with("1").and_return(@event)
        post :state, :id => "1", :morbidity_event => {:workflow_action => 'a_status'}
      end

      it "should redirect to the event index page" do
        do_change_state
        response.should redirect_to(cmrs_path)
      end
    end
  end
  
  describe "handling successful POST /cmrs/1/soft_delete with update entitlement" do
    
    before(:each) do
      mock_user
      @event = mock_event
      Event.stub!(:find).and_return(@event)
      @event.stub!(:read_attribute).and_return("MorbidityEvent")
      @user.stub!(:is_entitled_to_in?).and_return(true)
      @event.stub!(:add_note).and_return(true)
    end
    
    def do_post
      request.env['HTTP_REFERER'] = "/some_path"
      post :soft_delete, :id => "1"
    end

    it "should redirect to where the user came from" do
      @event.should_receive(:soft_delete).and_return(true)
      do_post
      response.should redirect_to("http://test.host/some_path")
    end
    
    it "should set the flash notice to a success message" do
      @event.should_receive(:soft_delete).and_return(true)
      do_post
      flash[:notice].should eql("The event was successfully marked as deleted.")
    end
  end
  
  describe "handling failed POST /cmrs/1/soft_delete with update entitlement" do
    
    before(:each) do
      mock_user
      @event = mock_event
      Event.stub!(:find).and_return(@event)
      @event.stub!(:read_attribute).and_return("MorbidityEvent")
      @user.stub!(:is_entitled_to_in?).and_return(true)
      @event.stub!(:add_note).and_return(true)
    end
    
    def do_post
      request.env['HTTP_REFERER'] = "/some_path"
      post :soft_delete, :id => "1"
    end

    it "should redirect to where the user came from" do
      @event.should_receive(:soft_delete).and_return(false)
      do_post
      response.should redirect_to("http://test.host/some_path")
    end
    
    it "should set the flash error to an error message" do
      @event.should_receive(:soft_delete).and_return(false)
      do_post
      flash[:error].should eql("An error occurred marking the event as deleted.")
    end

    it "should not add a note" do
      @event.should_receive(:soft_delete).and_return(false)
      @event.should_not_receive(:add_note)
      do_post
    end
  end
  
  describe "handling POST /cmrs/1/soft_delete without update entitlement" do
    
    before(:each) do
      mock_user
      @event = mock_event
      Event.stub!(:find).and_return(@event)
      @event.stub!(:read_attribute).and_return("MorbidityEvent")
      @user.stub!(:is_entitled_to_in?).and_return(false)
      @event.stub!(:add_note).and_return(true)
    end
    
    def do_post
      request.env['HTTP_REFERER'] = "/some_path"
      post :soft_delete, :id => "1"
    end

    it "should be be a 403" do
      do_post
      response.response_code.should == 403
    end

    it "should not add a note" do
      @event.should_not_receive(:add_note)
      do_post
    end
  end

end
