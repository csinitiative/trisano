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

require File.dirname(__FILE__) + '/../spec_helper'

describe EventAttachmentsController do

  before(:each) do
    mock_user
    @user.stubs(:is_entitled_to_in?).returns(true)
    @event = mock_event
    @event.stubs(:id).returns(1)
    @event.stubs(:save).returns(true)
    @event.stubs(:save!).returns(true)  #needed for EventTouchFilter
    Event.stubs(:find).returns(@event)
    User.stubs(:current_user).returns(@user)
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
      @attachment = Factory.build(:attachment)
      @user.stubs(:is_entitled_to_in?).returns(false)
      Attachment.stubs(:new).returns(@attachment)
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
      @attachment = Factory.build(:attachment)
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

  describe "handling GET /events/1/attachments/new with view event entitlement" do

    before(:each) do
      @attachment = Factory.build(:attachment)
      @user.stubs(:is_entitled_to_in?).returns(true)
      Attachment.stubs(:new).returns(@attachment)
    end

    def do_get
      @attachment.expects(:event_id=).with(1)
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
      @attachment = Factory.build(:attachment)
      @user.stubs(:is_entitled_to_in?).returns(false)
      Attachment.stubs(:new).returns(@attachment)
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
      @attachment = Factory.build(:attachment)
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

  describe "handling POST /events/1/attachments with update event entitlement" do

    before(:each) do
      @attachment = Factory.build(:attachment)
      @user.stubs(:is_entitled_to_in?).returns(true)
      Attachment.stubs(:new).returns(@attachment)
    end

    describe "with successful save" do

      def do_post
        request.env['HTTP_REFERER'] = "/some_path"
        @attachment.expects(:save).returns(true)
        post :create, :attachment => {}
      end

      it "should create a new attachment" do
        Attachment.expects(:new).returns(@attachment)
        do_post
      end

      it "should redirect to the referer" do
        do_post
        response.should redirect_to("/some_path")
      end

    end

    describe "with failed save" do

      def do_post
        @attachment.expects(:save).returns(false)
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
      @attachment = Factory.build(:attachment)
      @user.stubs(:is_entitled_to_in?).returns(false)
      Attachment.stubs(:new).returns(@attachment)
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
      @attachment = Factory.build(:attachment)
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

  describe "handling GET /events/1/attachments/1 with view event entitlement" do

    before(:each) do
      @user.stubs(:is_entitled_to_in?).returns(true)

      @attachments = []
      @event.stubs(:attachments).returns(@attachments)

      @attachment = Factory.build(:attachment)
      @attachment.stubs(:current_data).returns("some data")
      @attachment.stubs(:content_type).returns("text/plain")
      @attachment.stubs(:filename).returns("some_file.txt")

      @attachments.stubs(:find).returns(@attachment)
    end

    def do_get
      get :show, :event_id => "1", :id => "1"
    end
    
    it "should render a file" do
      @controller.expects(:send_data)
      @controller.stubs(:render) # http://www.nabble.com/%27Missing-template%27-when-using-send_data-to-render-response-td22538207.html
      do_get
      response.should be_success
    end

  end

  describe "handling GET /events/1/attachments/1 without view event entitlement" do

    before(:each) do
      @attachment = Factory.build(:attachment)
      @user.stubs(:is_entitled_to_in?).returns(false)
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
      @event.stubs(:attachments).returns(@attachments)
      @attachments.stubs(:find).raises(ActiveRecord::RecordNotFound)
      @user.stubs(:is_entitled_to_in?).returns(true)
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
