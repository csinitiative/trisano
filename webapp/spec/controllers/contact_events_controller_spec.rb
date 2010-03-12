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

describe ContactEventsController do
  before(:each) do
    mock_user
  end

  describe "handling GET /events" do

    before(:each) do
    end
  
    def do_get
      get :index
    end
  
    it "should return a 405" do
      do_get
      response.code.should == "405"
    end

    describe "handling GET /events/1 with view entitlement" do

      before(:each) do
        @event = mock_event
        Event.stubs(:find).returns(@event)
        @user.stubs(:is_entitled_to_in?).with(:view_event, 75).returns(true)
        @event.stubs(:read_attribute).returns('ContactEvent') 
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
        Event.expects(:find).with("75").returns(@event)
        do_get
      end
  
      it "should assign the found event for the view" do
        do_get
        assigns[:event].should equal(@event)
      end
    end
  
    describe "handling GET /events/1 without view entitlement" do

      before(:each) do
        @event = mock_event
        @event.stubs(:add_note)
        Event.stubs(:find).returns(@event)
        @user.stubs(:is_entitled_to_in?).returns(false)
        @event.stubs(:read_attribute).returns('ContactEvent') 
      end
  
      def do_get
        get :show, :id => "75"
      end

      it "should log access and be successful" do
        @event.expects(:add_note)
        do_get
        response.should be_success
      end

      it "should find the event requested" do
        Event.expects(:find).with("75").returns(@event)
        do_get
      end
  
    end

    describe "handling GETting a real event of the wrong type" do

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

    describe "handling GET /events/new" do
  
      def do_get
        get :new
      end
  
      it "should return a 405" do
        do_get
        response.code.should == "405"
      end
  
    end

    describe "handling GET /events/1/edit with update entitlement" do

      before(:each) do
        @event = mock_event
        @form_reference = Factory.build(:form_reference)
        @form = Factory.build(:form)

        Event.stubs(:find).returns(@event)
        @event.stubs(:get_investigation_forms).returns([@form])
        @user.stubs(:is_entitled_to_in?).with(:update_event, 75).returns(true)
        @event.stubs(:read_attribute).returns('ContactEvent') 
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
  
      it "should assign the found ContactEvent for the view" do
        do_get
        assigns[:event].should equal(@event)
      end
    end

  end
  
  describe "handling successful POST /contact_events/1/soft_delete with update entitlement" do
    
    before(:each) do
      mock_user
      @event = mock_event
      Event.stubs(:find).returns(@event)
      @event.stubs(:read_attribute).returns("ContactEvent")
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
  
  describe "handling failed POST /contact_events/1/soft_delete with update entitlement" do
    
    before(:each) do
      mock_user
      @event = mock_event
      Event.stubs(:find).returns(@event)
      @event.stubs(:read_attribute).returns("ContactEvent")
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
  
  describe "handling POST /contact_events/1/soft_delete without update entitlement" do
    
    before(:each) do
      mock_user
      @event = mock_event
      Event.stubs(:find).returns(@event)
      @event.stubs(:read_attribute).returns("ContactEvent")
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

  describe 'handling GET contact_events/copy_address/1' do
    before :each do
      @address = Factory.build(:address,
                               :street_number => '555',
                               :street_name   => 'Happy St.',
                               :unit_number   => nil,
                               :city          => 'Provo',
                               :state_id      => '1',
                               :county_id     => '2',
                               :postal_code   => '99999')
      @parent_event = Factory.build(:morbidity_event, :address => @address)
      @event = Factory.build(:contact_event, :parent_event => @parent_event)
      ContactEvent.expects(:find).with('1').returns(@event)
    end

    def do_get
      get :copy_address, :id => 1
    end

    it 'should return address as JSON' do
      do_get
      response.headers["X-JSON"].should == "{street_number: \"555\", street_name: \"Happy St.\", unit_number: \"\", city: \"Provo\", state_id: \"1\", county_id: \"2\", postal_code: \"99999\"}"
    end
  end
      
end
