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

describe EventTasksController do
  
  before(:each) do
    mock_user
    @event = mock_event
    @event.stubs(:id).returns(1)
    @event.stubs(:save).returns(true)
    @event.stubs(:save!).returns(true)  #needed for EventTouchFilter
    Event.stubs(:find).returns(@event)
  end

  describe "handling GET /events/1/tasks with view event entitlement" do

    before(:each) do
      @task = Factory.build(:task)
      @user.stubs(:is_entitled_to_in?).returns(true)
      Task.stubs(:new).returns(@task)
    end
  
    def do_get
      get :index, :event_id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render new template" do
      do_get
      response.should render_template('index')
    end

  end

  describe "handling GET /events/1/tasks without view event entitlement" do

    before(:each) do
      @task = Factory.build(:task)
      @user.stubs(:is_entitled_to_in?).returns(false)
      Task.stubs(:new).returns(@task)
    end

    def do_get
      get :index, :event_id => "1"
    end

    it "should not be successful" do
      do_get
      response.response_code.should == 403
    end

    it "should contain permissions error" do
      do_get
      response.should render_template('events/_permission_denied')
    end

  end

  describe "handling GET /events/1/tasks without a valid event" do

    before(:each) do
      @task = Factory.build(:task)
      @user.stubs(:is_entitled_to_in?).returns(true)
      Event.stubs(:find).raises(ActiveRecord::RecordNotFound)
    end

    def do_get
      get :index, :event_id => "1"
    end

    it "should not be successful" do
      do_get
      response.response_code.should == 404
    end

  end

  describe "handling ajax GET /events/1/tasks" do
    
    def do_xhr
      xhr :get, :index, :event_id => "1"
    end    

    it 'should respond to xhr requests' do
      do_xhr
      response.should be_success
    end

    it 'should render the list tasks partial' do
      do_xhr
      response.should render_template('tasks/_list.html.haml')
    end
      
  end

  describe "handling GET /events/1/tasks/new with update event entitlement" do

    before(:each) do
      @task = Factory.build(:task)
      @user.stubs(:is_entitled_to_in?).returns(true)
      Task.stubs(:new).returns(@task)
    end

    def do_get
      @task.expects(:event_id=).with(1)
      get :new, :event_id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render new template" do
      do_get
      response.should render_template('new')
    end

    it "should assign the task with its event id set for the view" do
      do_get
      assigns[:task].should == @task
    end

  end

  describe "handling GET /events/1/tasks/new without update event entitlement" do

    before(:each) do
      @task = Factory.build(:task)
      @user.stubs(:is_entitled_to_in?).returns(false)
      Task.stubs(:new).returns(@task)
    end

    def do_get
      get :new, :event_id => "1"
    end

    it "should not be successful" do
      do_get
      response.response_code.should == 403
    end

    it "should contain permissions error" do
      do_get
      response.should render_template('events/_permission_denied')
    end

  end

  describe "handling GET /events/1/tasks/new without a valid event" do

    before(:each) do
      @task = Factory.build(:task)
      @user.stubs(:is_entitled_to_in?).returns(true)
      Event.stubs(:find).raises(ActiveRecord::RecordNotFound)
    end

    def do_get
      get :new, :event_id => "1"
    end

    it "should not be successful" do
      do_get
      response.response_code.should == 404
    end

  end

  describe "handling GET /events/1/tasks/1/edit" do

    before(:each) do
      mock_user
      @task = Factory.build(:task)
      @user.stubs(:is_entitled_to_in?).returns(true)
      @proxy = mock('proxy')
      @proxy.stubs(:find).returns(@task)
      @event.stubs(:tasks).returns(@proxy)
    end

    def do_get
      get :edit, :event_id => "1", :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end

    it "should assign the found task for the view" do
      do_get
      assigns[:task].should equal(@task)
    end
  end

  describe "handling POST /events/1/tasks with update event entitlement" do

    before(:each) do
      @task = Factory.build(:task)
      @user.stubs(:is_entitled_to_in?).returns(true)
      @task.stubs(:user_id).returns(nil)
      Task.stubs(:new).returns(@task)
    end

    describe "with successful save" do

      def do_post
        @task.expects(:user_id=).once()
        @task.expects(:save).returns(true)
        post :create, :task => {}
      end

      it "should create a new task" do
        Task.expects(:new).returns(@task)
        do_post
      end

      it "should redirect to the event tasks path" do
        do_post
        response.should redirect_to(event_tasks_path(@event))
      end

    end

    describe "with failed save" do

      def do_post
        @task.expects(:user_id=).once()
        @task.expects(:save).returns(false)
        post :create, :task => {}
      end

      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end

    end
  end

  describe "handling POST /events/1/tasks without update event entitlement" do

    before(:each) do
      @task = Factory.build(:task)
      @user.stubs(:is_entitled_to_in?).returns(false)
      @task.stubs(:user_id).returns(nil)
      Task.stubs(:new).returns(@task)
    end

    describe "with save attempt" do

      def do_post
        request.env['HTTP_REFERER'] = "/some_path"
        post :create
      end

      it "should not be successful" do
        do_post
        response.response_code.should == 403
      end

      it "should contain permissions error" do
        do_post
        response.should render_template('events/_permission_denied')
      end

    end
  end

  describe "handling POST /events/1/tasks without a valid event" do

    before(:each) do
      @task = Factory.build(:task)
      @user.stubs(:is_entitled_to_in?).returns(true)
      Event.stubs(:find).raises(ActiveRecord::RecordNotFound)
    end

    def do_get
      get :create, :event_id => "1"
    end

    it "should not be successful" do
      do_get
      response.response_code.should == 404
    end

  end

  describe "handling PUT /events/1/task/1 with update event entitlement" do

    before(:each) do
      @task = Factory.build(:task)
      @user.stubs(:is_entitled_to_in?).returns(true)
      @task.stubs(:user_id).returns(nil)

      @proxy = mock('proxy')
      @proxy.stubs(:find).returns(@task)
      @event.stubs(:tasks).returns(@proxy)
      @task.save(false)
    end

    describe "with successful update" do

      def do_put
        @task.expects(:update_attributes).returns(true)
        put :update, :task => {}
      end

      it "should redirect to the edit event tasks path" do
        do_put
        response.should redirect_to(edit_event_task_path(@event, @task))
      end

      it "should set the flash notice to a success message" do
        do_put
        flash[:notice].should eql("Task was successfully updated.")
      end

    end

    describe "with failed update" do

      def do_put
        @task.expects(:update_attributes).returns(false)
        put :update, :task => {}
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling PUT /events/1/task/1 with update event entitlement through Ajax request" do

    before(:each) do
      request.env["HTTP_ACCEPT"] = "application/javascript"
      @task = Factory.build(:task)
      @user.stubs(:is_entitled_to_in?).returns(true)
      @task.stubs(:user_id).returns(nil)

      @proxy = mock('proxy')
      @proxy.stubs(:find).returns(@task)
      @event.stubs(:tasks).returns(@proxy)
    end

    describe "with successful update" do

      def do_put
        @task.expects(:update_attributes).returns(true)
        put :update, :task => {}
      end

      it "should render 'update'" do
        do_put
        response.should render_template('update')
      end

      it "should set the flash notice to a success message" do
        do_put
        flash[:notice].should eql("Task was successfully updated.")
      end

    end

    describe "with failed update" do

      def do_put
        @task.expects(:update_attributes).returns(false)
        put :update, :task => {}
      end

      it "should render 'update'" do
        do_put
        response.should render_template('update')
      end

      it "should set the flash error to a failure message" do
        do_put
        flash[:error].should eql("Could not update task.")
      end

    end
  end

  context "handling an XML request" do
    it "should return a head 404 response to an XML request" do
      login_as_super_user
      request.env['HTTP_ACCEPT'] = 'application/xml'
      Event.stubs(:find).raises("no such event")
      get :new, :event_id => 1
      response.status.should == "404 Not Found"
      response.body.should be_blank
    end
  end

end
