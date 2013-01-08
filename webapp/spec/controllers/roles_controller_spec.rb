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

describe RolesController do
  describe "handling GET /roles" do

    before(:each) do
      mock_user
      @role = Factory.build(:role)
      Role.stubs(:find).returns([@role])
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
  
    it "should find all roles" do
      Role.expects(:find).returns([@role])
      do_get
    end
  
    it "should assign the found roles for the view" do
      do_get
      assigns[:roles].should == [@role]
    end
  end

  describe "handling GET /roles.xml" do

    before(:each) do
      mock_user
      @role = Factory.build(:role)
      Role.stubs(:find).returns(@role)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all roles" do
      Role.expects(:find).returns([@role])
      do_get
    end
  
    it "should render the found roles as xml" do
      @role.expects(:to_xml).returns("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /roles/1" do

    before(:each) do
      mock_user
      @role = Factory.build(:role)
      Role.stubs(:find).returns(@role)
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
  
    it "should find the role requested" do
      Role.expects(:find).with("1").returns(@role)
      do_get
    end
  
    it "should assign the found role for the view" do
      do_get
      assigns[:role].should equal(@role)
    end
  end

  describe "handling GET /roles/1.xml" do

    before(:each) do
      mock_user
      @role = Factory.build(:role)
      Role.stubs(:find).returns(@role)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the role requested" do
      Role.expects(:find).with("1").returns(@role)
      do_get
    end
  
    it "should render the found role as xml" do
      @role.expects(:to_xml).returns("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /roles/new" do

    before(:each) do
      mock_user
      @role = Factory.build(:role)
      Role.stubs(:new).returns(@role)
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
  
    it "should create an new role" do
      Role.expects(:new).returns(@role)
      do_get
    end
  
    it "should not save the new role" do
      @role.expects(:save).never
      do_get
    end
  
    it "should assign the new role for the view" do
      do_get
      assigns[:role].should equal(@role)
    end
  end

  describe "handling GET /roles/1/edit" do

    before(:each) do
      mock_user
      @role = Factory.build(:role)
      Role.stubs(:find).returns(@role)
    end
  
    def do_get
      get :edit, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the role requested" do
      Role.expects(:find).returns(@role)
      do_get
    end
  
    it "should assign the found Role for the view" do
      do_get
      assigns[:role].should equal(@role)
    end
  end

  describe "handling POST /roles" do

    before(:each) do
      mock_user
      @role = Factory.create(:role)
      Role.stubs(:new).returns(@role)
    end
    
    describe "with successful save" do
  
      def do_post
        @role.expects(:save).returns(true)
        post :create, :role => {}
      end
  
      it "should create a new role" do
        Role.expects(:new).with({}).returns(@role)
        do_post
      end

      it "should redirect to the new role" do
        do_post
        response.should redirect_to(role_url(@role))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @role.expects(:save).returns(false)
        post :create, :role => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /roles/1" do

    before(:each) do
      mock_user
      @role = Factory.create(:role)
      Role.stubs(:find).returns(@role)
    end
    
    describe "with successful update" do

      def do_put
        @role.expects(:update_attributes).returns(true)
        put :update, :role => {}, :id => "1"
      end

      it "should find the role requested" do
        Role.expects(:find).with("1").returns(@role)
        do_put
      end

      it "should update the found role" do
        do_put
        assigns(:role).should equal(@role)
      end

      it "should assign the found role for the view" do
        do_put
        assigns(:role).should equal(@role)
      end

      it "should redirect to the role" do
        do_put
        response.should redirect_to(role_url(@role))
      end

    end
    
    describe "with failed update" do

      def do_put
        @role.expects(:update_attributes).returns(false)
        put :update, :role => {}, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /roles/1" do

    before(:each) do
      mock_user
      @role = Factory.build(:role)
      Role.stubs(:find).returns(@role)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the role requested" do
      Role.expects(:find).with("1").returns(@role)
      do_delete
    end
  
    it "should call destroy on the found role" do
      @role.expects(:destroy)
      do_delete
    end
  
    it "should redirect to the roles list" do
      do_delete
      response.should redirect_to(roles_url)
    end
  end
end
