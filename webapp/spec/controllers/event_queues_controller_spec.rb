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

require File.dirname(__FILE__) + '/../spec_helper'

describe EventQueuesController do
  before(:each) do
    mock_user
    @user.stubs(:jurisdiction_ids_for_privilege).with(:administer).returns([75])
  end

  describe "handling GET /event_queues" do

    before(:each) do
      @event_queue = Factory.create(:event_queue)
      EventQueue.stubs(:find).returns([@event_queue])
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

    it "should find all event_queues" do
      EventQueue.expects(:find).returns([@event_queue])
      do_get
    end

    it "should assign the found event_queues for the view" do
      do_get
      assigns[:event_queues].should == [@event_queue]
    end
  end

  describe "handling GET /event_queues.xml" do

    before(:each) do
      @event_queue = Factory.create(:event_queue)
      EventQueue.stubs(:find).returns(@event_queue)
    end

    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all event_queues" do
      EventQueue.expects(:find).returns([@event_queue])
      do_get
    end

    it "should render the found event_queues as xml" do
      @event_queue.expects(:to_xml).returns("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /event_queues/1" do

    before(:each) do
      @event_queue = Factory.create(:event_queue)
      EventQueue.stubs(:find).returns(@event_queue)
    end

    def do_get
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render show template" do
      do_get
      response.should render_template('show')
    end

    it "should find the event_queue requested" do
      EventQueue.expects(:find).with("1").returns(@event_queue)
      do_get
    end

    it "should assign the found event_queue for the view" do
      do_get
      assigns[:event_queue].should equal(@event_queue)
    end
  end

  describe "handling GET /event_queues/1.xml" do

    before(:each) do
      @event_queue = Factory.create(:event_queue)
      EventQueue.stubs(:find).returns(@event_queue)
    end

    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find the event_queue requested" do
      EventQueue.expects(:find).with("1").returns(@event_queue)
      do_get
    end

    it "should render the found event_queue as xml" do
      @event_queue.expects(:to_xml).returns("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /event_queues/new" do

    before(:each) do
      @event_queue = Factory.create(:event_queue)
      EventQueue.stubs(:new).returns(@event_queue)
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

    it "should create an new event_queue" do
      EventQueue.expects(:new).returns(@event_queue)
      do_get
    end

    it "should not save the new event_queue" do
      @event_queue.expects(:save).never
      do_get
    end

    it "should assign the new event_queue for the view" do
      do_get
      assigns[:event_queue].should equal(@event_queue)
    end
  end

  describe "handling GET /event_queues/1/edit" do

    def do_get
      get :edit, :id => "1"
    end

    before(:each) do
      @event_queue = Factory.create(:event_queue)
      EventQueue.stubs(:find).returns(@event_queue)
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end

    it "should find the event_queue requested" do
      EventQueue.expects(:find).returns(@event_queue)
      do_get
    end

    it "should assign the found EventQueue for the view" do
      do_get
      assigns[:event_queue].should equal(@event_queue)
    end
  end

  describe "handling POST /event_queues" do

    before(:each) do
      @event_queue = Factory.create(:event_queue)
      EventQueue.stubs(:new).returns(@event_queue)
    end

    describe "with successful save" do

      def do_post
        @event_queue.expects(:save).returns(true)
        post :create, :event_queue => {}
      end

      it "should create a new event_queue" do
        EventQueue.expects(:new).with({}).returns(@event_queue)
        do_post
      end

      it "should redirect to the new event_queue" do
        do_post
        response.should redirect_to(event_queue_url(@event_queue))
      end

    end

    describe "with failed save" do

      def do_post
        @event_queue.expects(:save).returns(false)
        post :create, :event_queue => {}
      end

      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end

    end
  end

  describe "handling PUT /event_queues/1" do

    before(:each) do
      @event_queue = Factory.create(:event_queue)
      EventQueue.stubs(:find).returns(@event_queue)
    end

    describe "with successful update" do

      def do_put
        @event_queue.expects(:update_attributes).returns(true)
        put :update, :id => "1"
      end

      it "should find the event_queue requested" do
        EventQueue.expects(:find).with("1").returns(@event_queue)
        do_put
      end

      it "should update the found event_queue" do
        do_put
        assigns(:event_queue).should equal(@event_queue)
      end

      it "should assign the found event_queue for the view" do
        do_put
        assigns(:event_queue).should equal(@event_queue)
      end

      it "should redirect to the event_queue" do
        do_put
        response.should redirect_to(event_queue_url(@event_queue))
      end

    end

    describe "with failed update" do

      def do_put
        @event_queue.expects(:update_attributes).returns(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /event_queues/1" do

    before(:all) do
      destroy_fixture_data
    end

    after(:all) do
      Fixtures.reset_cache
    end

    before(:each) do
      destroy_fixture_data
      @event_queue = Factory.create(:event_queue)
      EventQueue.stubs(:find).returns(@event_queue)
    end

    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the event_queue requested" do
      EventQueue.expects(:find).with("1").returns(@event_queue)
      do_delete
    end

    it "should call destroy on the found event_queue" do
      @event_queue.expects(:destroy)
      do_delete
    end

    it "should redirect to the event_queues list" do
      do_delete
      response.should redirect_to(event_queues_url)
    end
  end
end
