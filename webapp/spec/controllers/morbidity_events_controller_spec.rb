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

# Many specs are commented out. The mocking exercise is not a small undertaking.
# Perhaps it can be chipped away at.

describe MorbidityEventsController do
  describe "handling GET /events" do

    before(:each) do
      mock_user
      @event = mock_event
      Event.stubs(:find_by_sql).returns([@event])
      @user.stubs(:jurisdiction_ids_for_privilege).with(:view_event).returns([75])
      @event.stubs(:read_attribute).returns('MorbidityEvent')
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
      MorbidityEvent.expects(:find_all_for_filtered_view).with(kind_of(Hash)).returns([@event])
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
      Event.stubs(:find).returns(@event)
      @user.stubs(:is_entitled_to_in?).with(:view_event, 75).returns(true)
      @event.stubs(:read_attribute).returns('MorbidityEvent')
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
      Event.expects(:find).once().with("75").returns(@event)
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
      Event.stubs(:find).returns(@event)
      @user.stubs(:is_entitled_to_in?).with(:view_event, 75).returns(true)
      @event.stubs(:read_attribute).returns('ContactEvent')
    end

    def do_get
      get :show, :id => "75"
    end

    it "should find the event requested" do
      Event.expects(:find).with("75").returns(@event)
      do_get
    end

    it "should return a 404" do
      do_get
      response.response_code.should == 404
    end

    it "should render the public 404 page" do
      do_get
      response.should render_template("#{RAILS_ROOT}/public/404.en.html")
    end

  end

  describe "handling GET /events/1 without view entitlement" do

    before(:each) do
      mock_user
      @event = mock_event
      @event.stubs(:add_note)
      Event.stubs(:find).returns(@event)
      @user.stubs(:is_entitled_to_in?).returns(false)
      @event.stubs(:read_attribute).returns('MorbidityEvent')
    end

    def do_get
      get :show, :id => "75"
    end

    it "should find the event requested" do
      Event.expects(:find).with("75").returns(@event)
      do_get
    end

    it "should log access and be successful" do
      @event.expects(:add_note)
      do_get
      response.should be_success
    end

  end

  describe "handling GET /events/new" do

    before(:each) do
      mock_user
      @event = mock_event
      MorbidityEvent.stubs(:new).returns(@event)
      @user.stubs(:is_entitled_to?).with(:create_event).returns(true)
      @event.stubs(:read_attribute).returns('MorbidityEvent')
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
      MorbidityEvent.expects(:new).returns(@event)
      do_get
    end

    it "should not save the new event" do
      @event.expects(:save).never
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
      @form_reference = Factory.build(:form_reference)
      @form = Factory.build(:form)

      Event.stubs(:find).returns(@event)
      @event.stubs(:get_investigation_forms).returns([@form])
      @user.stubs(:is_entitled_to_in?).with(:update_event, 75).returns(true)
      @event.stubs(:read_attribute).returns('MorbidityEvent')
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
      Event.expects(:find).returns(@event)
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
      @user.stubs(:is_entitled_to_in?).with(:route_event_to_any_lhd, 1).returns(true)
      @user.stubs(:is_entitled_to_in?).with(:create_event, "2").returns(true)
      @user.stubs(:jurisdiction_ids_for_privilege).with(:view_event).returns([1])

      @jurisdiction = Factory.build(:jurisdiction)
      @jurisdiction.stubs(:secondary_entity_id).returns(1)

      @primary_jurisdiction = Factory.build(:place)
      @primary_jurisdiction.stubs(:is_unassigned_jurisdiction?).returns(false)

      @event = Factory.build(:morbidity_event)
      @event.stubs(:jurisdiction).returns(@jurisdiction)
      @event.stubs(:update_attribute).returns(true)
      @event.stubs(:primary_jurisdiction).returns(@primary_jurisdiction)
      MorbidityEvent.stubs(:find).returns(@event)
    end

    describe "with successful routing" do
      def do_route_event
        Event.expects(:find).returns(@event)
        request.env['HTTP_REFERER'] = "/some_path"
        @event.expects(:assign_to_lhd)
        @event.expects(:save!)
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
            @jurisdiction.stubs(:secondary_entity_id).returns(2)
            @event.expects(:update_attribute).never
            do_route_event
          end
        end
      end

      describe "with secondary_ids too" do
        it "should pass IDs into event#route_to_jurisdiction" do
          Event.expects(:find).returns(@event)
          @event.expects(:assign_to_lhd)
          @event.expects(:save!)
          request.env['HTTP_REFERER'] = "/some_path"
          post :jurisdiction, :id => "1", :jurisdiction_id => "2", :secondary_jurisdiction_ids => ["3", "4"], :note => ""
        end
      end
    end

  end

  describe "handling STATE actions /events/1/state" do
    def set_up_mocks
      mock_user
      @user.stubs(:is_entitled_to_in?).with(:a_privilege, 1).returns(true)
      @user.stubs(:jurisdiction_ids_for_privilege).with(:view_event).returns([1])

      @jurisdiction = Factory.build(:jurisdiction)
      @jurisdiction.stubs(:secondary_entity_id).returns(1)

      @event = Factory.build(:morbidity_event)
      @event.stubs(:jurisdiction).returns(@jurisdiction)
      @event.stubs(:update_attributes).returns(true)
      @event.stubs(:attributes=).returns(1)
      @event.stubs(:investigator_id=).returns(@user.id)
      @event.stubs(:investigation_started_date=)
      @event.stubs(:add_note)
      MorbidityEvent.stubs(:find).returns(@event)
      ExternalCode.stubs(:event_code_str).returns("A_PRIV")
    end

    describe "with successful state change" do
      before(:each) do
        set_up_mocks
      end

      def do_change_state
        Event.expects(:find).with("1").returns(@event)
        request.env['HTTP_REFERER'] = "/some_path"
        @event.expects(:a_status)
        @event.expects(:save).returns(true)
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
        event = Factory.build(:morbidity_event)
        event.expects(:halted?).returns true
        Event.expects(:find).with("1").returns(event)

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
        event = Factory.build(:morbidity_event)
        event.expects(:halted?).returns true
        Event.expects(:find).returns(event)

        post :state, :id => "1", :morbidity_event => {:event_status => 'a_status'}
      end

      it "should respond with a 403" do
        do_change_state
        response.code.should == "403"
      end
    end

  end

  describe "handling successful POST /cmrs/1/soft_delete with update entitlement" do

    before(:each) do
      mock_user
      @event = mock_event
      Event.stubs(:find).returns(@event)
      @event.stubs(:read_attribute).returns("MorbidityEvent")
      @user.stubs(:is_entitled_to_in?).returns(true)
      @event.stubs(:add_note).returns(true)
    end

    def do_post
      request.env['HTTP_REFERER'] = "/some_path"
      post :soft_delete, :id => "1"
    end

    it "should redirect to where the user came from" do
      @event.expects(:soft_delete).returns(true)
      do_post
      response.should redirect_to("http://test.host/some_path")
    end

    it "should set the flash notice to a success message" do
      @event.expects(:soft_delete).returns(true)
      do_post
      flash[:notice].should eql("The event was successfully marked as deleted.")
    end
  end

  describe "handling failed POST /cmrs/1/soft_delete with update entitlement" do

    before(:each) do
      mock_user
      @event = mock_event
      Event.stubs(:find).returns(@event)
      @event.stubs(:read_attribute).returns("MorbidityEvent")
      @user.stubs(:is_entitled_to_in?).returns(true)
      @event.stubs(:add_note).returns(true)
    end

    def do_post
      request.env['HTTP_REFERER'] = "/some_path"
      post :soft_delete, :id => "1"
    end

    it "should redirect to where the user came from" do
      @event.expects(:soft_delete).returns(false)
      do_post
      response.should redirect_to("http://test.host/some_path")
    end

    it "should set the flash error to an error message" do
      @event.expects(:soft_delete).returns(false)
      do_post
      flash[:error].should eql("An error occurred marking the event as deleted.")
    end

    it "should not add a note" do
      @event.expects(:soft_delete).returns(false)
      @event.expects(:add_note).never
      do_post
    end
  end

  describe "handling POST /cmrs/1/soft_delete without update entitlement" do

    before(:each) do
      mock_user
      @event = mock_event
      Event.stubs(:find).returns(@event)
      @event.stubs(:read_attribute).returns("MorbidityEvent")
      @user.stubs(:is_entitled_to_in?).returns(false)
      @event.stubs(:add_note).returns(true)
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
      @event.expects(:add_note).never
      do_post
    end
  end

end
