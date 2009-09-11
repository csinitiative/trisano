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

describe EventAttachmentsController do

  before(:each) do
    mock_user
    @user.stub!(:is_entitled_to_in?).and_return(true)
    @event = mock_event
    @event.stub!(:id).and_return(1)
    @event.stub!(:save).and_return(true)
    Event.stub!(:find).and_return(@event)
    User.stub!(:current_user).and_return(@user)
  end
  
  describe "handling GET /events/1/attachments with view event entitlement" do

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

  describe "handling GET /events/1/attachments without view event entitlement" do

    before(:each) do
      @attachment = mock_model(Attachment)
      @user.stub!(:is_entitled_to_in?).and_return(false)
      Attachment.stub!(:new).and_return(@attachment)
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

  describe "handling GET /events/1/attachments without a valid event" do

    before(:each) do
      @attachment = mock_model(Attachment)
      @user.stub!(:is_entitled_to_in?).and_return(true)
      Event.stub!(:find).and_raise(ActiveRecord::RecordNotFound)
    end

    def do_get
      get :index, :event_id => "1"
    end

    it "should not be successful" do
      do_get
      response.response_code.should == 404
    end

  end

  describe "handling GET /events/1/attachments/new with view event entitlement" do

    before(:each) do
      @attachment = mock_model(Attachment)
      @user.stub!(:is_entitled_to_in?).and_return(true)
      Attachment.stub!(:new).and_return(@attachment)
    end

    def do_get
      @attachment.should_receive(:event_id=).with(1)
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

    it "should assign the attachment with its event id set for the view" do
      do_get
      assigns[:attachment].should == @attachment
    end

  end

  describe "handling GET /events/1/attachments/new without update event entitlement" do

    before(:each) do
      @attachment = mock_model(Attachment)
      @user.stub!(:is_entitled_to_in?).and_return(false)
      Attachment.stub!(:new).and_return(@attachment)
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

  describe "handling GET /events/1/attachments/new without a valid event" do

    before(:each) do
      @attachment = mock_model(Attachment)
      @user.stub!(:is_entitled_to_in?).and_return(true)
      Event.stub!(:find).and_raise(ActiveRecord::RecordNotFound)
    end

    def do_get
      get :new, :event_id => "1"
    end

    it "should not be successful" do
      do_get
      response.response_code.should == 404
    end

  end

  describe "handling POST /events/1/attachments with update event entitlement" do

    before(:each) do
      @attachment = mock_model(Attachment)
      @user.stub!(:is_entitled_to_in?).and_return(true)
      Attachment.stub!(:new).and_return(@attachment)
    end

    describe "with successful save" do

      def do_post
        request.env['HTTP_REFERER'] = "/some_path"
        @attachment.should_receive(:save).and_return(true)
        post :create, :attachment => {}
      end

      it "should create a new attachment" do
        Attachment.should_receive(:new).and_return(@attachment)
        do_post
      end

      it "should redirect to the referer" do
        do_post
        response.should redirect_to("/some_path")
      end

    end

    describe "with failed save" do

      def do_post
        @attachment.should_receive(:save).and_return(false)
        post :create, :attachment => {}
      end

      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end

    end
  end

  describe "handling POST /events/1/attachment without update event entitlement" do

    before(:each) do
      @attachment = mock_model(Attachment)
      @user.stub!(:is_entitled_to_in?).and_return(false)
      Attachment.stub!(:new).and_return(@attachment)
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

  describe "handling POST /attachment/1/attachments without a valid event" do

    before(:each) do
      @attachment = mock_model(Attachment)
      @user.stub!(:is_entitled_to_in?).and_return(true)
      Event.stub!(:find).and_raise(ActiveRecord::RecordNotFound)
    end

    def do_get
      get :create, :event_id => "1"
    end

    it "should not be successful" do
      do_get
      response.response_code.should == 404
    end

  end

  describe "handling GET /events/1/attachments/1 with view event entitlement" do

    before(:each) do
      @user.stub!(:is_entitled_to_in?).and_return(true)

      @attachments = []
      @event.stub!(:attachments).and_return(@attachments)

      @attachment = mock_model(Attachment)
      @attachment.stub!(:current_data).and_return("some data")
      @attachment.stub!(:content_type).and_return("text/plain")
      @attachment.stub!(:filename).and_return("some_file.txt")

      @attachments.stub!(:find).and_return(@attachment)
    end

    def do_get
      get :show, :event_id => "1", :id => "1"
    end
    
    it "should render a file" do
      @controller.should_receive(:send_data)
      @controller.stub!(:render) # http://www.nabble.com/%27Missing-template%27-when-using-send_data-to-render-response-td22538207.html
      do_get
      response.should be_success
    end

  end

  describe "handling GET /events/1/attachments/1 without view event entitlement" do

    before(:each) do
      @attachment = mock_model(Attachment)
      @user.stub!(:is_entitled_to_in?).and_return(false)
    end

    def do_get
      get :show, :event_id => "1", :id => "1"
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

  describe "handling GET /events/1/attachments/1 for a file that doesn't exist" do

    before(:each) do
      @attachments = []
      @event.stub!(:attachments).and_return(@attachments)
      @attachments.stub!(:find).and_raise(ActiveRecord::RecordNotFound)
      @user.stub!(:is_entitled_to_in?).and_return(true)
    end

    def do_get
      get :show, :event_id => "1", :id => "1"
    end

    it "should not be successful" do
      do_get
      response.response_code.should == 404
    end

  end

end
