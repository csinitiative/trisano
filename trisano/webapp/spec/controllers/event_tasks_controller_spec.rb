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

describe EventTasksController do
  
  before(:each) do
    mock_user
    @event = mock_model(Event, :to_param => "1")
    @event.stub!(:id).and_return(1)
    Event.stub!(:find).and_return(@event)
  end

  describe "handling GET /events/1/tasks" do

    before(:each) do
      @task = mock_model(Task)
      Task.stub!(:new).and_return(@task)
    end
  
    def do_get
      @task.should_receive(:event_id=).with(1)
      get :index, :event_id => "1"
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

  describe "handling GET /events/1/tasks/new" do

    before(:each) do
      @task = mock_model(Task)
      Task.stub!(:new).and_return(@task)
    end

    def do_get
      @task.should_receive(:event_id=).with(1)
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

  describe "handling POST /events/1/tasks" do

    before(:each) do
      @task = mock_model(Task)
      Task.stub!(:new).and_return(@task)
    end

    describe "with successful save" do

      def do_post
        request.env['HTTP_REFERER'] = "/some_path"
        @task.should_receive(:user_id=).once()
        @task.should_receive(:save).and_return(true)
        post :create
      end

      it "should create a new task" do
        Task.should_receive(:new).and_return(@task)
        do_post
      end

      it "should redirect to the referer" do
        do_post
        response.should redirect_to("/some_path")
      end

    end

    describe "with failed save" do

      def do_post
        @task.should_receive(:user_id=).once()
        @task.should_receive(:save).and_return(false)
        post :create
      end

      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end

    end
    
  end

end
