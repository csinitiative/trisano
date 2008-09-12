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

describe FollowUpElementsController do
  describe "handling GET /follow_up_elements" do
    before(:each) do
      mock_user
      @follow_up_element = mock_model(FollowUpElement)
    end
  
    def do_get
      get :index
    end
  
    it "should not be successful as the method is not currently supported" do
      do_get
      response.should_not be_success
      response.headers["Status"].should =~ /405/
    end
  end
  
  describe "handling GET /follow_up_elements.xml" do
    before(:each) do
      mock_user
      @follow_up_element = mock_model(FollowUpElement, :to_xml => "XML")
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should not be successful as the method is not currently supported" do
      do_get
      response.should_not be_success
      response.headers["Status"].should =~ /405/
    end
  end

  describe "handling GET /follow_up_elements/1" do
    before(:each) do
      mock_user
      @follow_up_element = mock_model(FollowUpElement)
    end
  
    def do_get
      get :show, :id => "1"
    end

    it "should not be successful as the method is not currently supported" do
      do_get
      response.should_not be_success
      response.headers["Status"].should =~ /405/
    end
  end

  describe "handling GET /follow_up_elements/1.xml" do

    before(:each) do
      mock_user
      @follow_up_element = mock_model(FollowUpElement, :to_xml => "XML")
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should not be successful as the method is not currently supported" do
      do_get
      response.should_not be_success
      response.headers["Status"].should =~ /405/
    end
  end

  describe "handling GET /follow_up_elements/new" do

    before(:each) do
      mock_user
      @follow_up_element = mock_model(FollowUpElement)
      FollowUpElement.stub!(:new).and_return(@follow_up_element)
      @follow_up_element.stub!(:parent_element_id=)
      @follow_up_element.stub!(:core_data=)
      @follow_up_element.stub!(:event_type=)
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
  
    it "should create an new follow_up_element" do
      FollowUpElement.should_receive(:new).and_return(@follow_up_element)
      do_get
    end
  
    it "should not save the new follow_up_element" do
      @follow_up_element.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new follow_up_element for the view" do
      do_get
      assigns[:follow_up_element].should equal(@follow_up_element)
    end
  end

  describe "handling GET /follow_up_elements/1/edit" do

    before(:each) do
      mock_user
      @follow_up_element = mock_model(FollowUpElement)
      FollowUpElement.stub!(:find).and_return(@follow_up_element)
    end
  
    def do_get
      get :edit, :id => "1"
    end

  end

  describe "handling POST /follow_up_elements" do

    before(:each) do
      mock_user
      @follow_up_element = mock_model(FollowUpElement, :to_param => "1")
      @follow_up_element.stub!(:form_id).and_return(1)
      FollowUpElement.stub!(:new).and_return(@follow_up_element)
    end
    
    describe "with successful save" do
  
      def do_post
        @request.env["HTTP_ACCEPT"] = "application/javascript"
        @follow_up_element.should_receive(:save_and_add_to_form).and_return(true)
        Form.stub!(:find).with(1).and_return(mock_model(Form))
        post :create, :follow_up_element => {}
      end
  
      it "should create a new follow_up_element" do
        FollowUpElement.should_receive(:new).with({}).and_return(@follow_up_element)
        do_post
      end

      it "should render the create template" do
        do_post
        response.should render_template('create')
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @request.env["HTTP_ACCEPT"] = "application/javascript"
        @follow_up_element.should_receive(:save_and_add_to_form).and_return(false)
        @follow_up_element.errors.should_receive(:each)
        post :create, :follow_up_element => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /follow_up_elements/1" do

    before(:each) do
      mock_user
      @follow_up_element = mock_model(FollowUpElement, :to_param => "1")
    end
    
    describe "with successful update" do

      def do_put
        put :update, :id => "1"
      end

      it "should not be successful as the method is not currently supported" do
        do_put
        response.should_not be_success
        response.headers["Status"].should =~ /405/
      end

    end
    
    describe "with failed update" do

      def do_put
        put :update, :id => "1"
      end

      it "should not be successful as the method is not currently supported" do
        do_put
        response.should_not be_success
        response.headers["Status"].should =~ /405/
      end

    end
  end

  describe "handling DELETE /follow_up_elements/1" do

    before(:each) do
      mock_user
      @follow_up_element = mock_model(FollowUpElement, :destroy => true)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should not be successful as the method is not currently supported" do
      do_delete
      response.should_not be_success
      response.headers["Status"].should =~ /405/
    end
  end
  
  describe "handling POST /auto_complete_for_core_follow_up_conditions" do
     
    before(:each) do
      mock_user
      @items = []
      ExternalCode.stub!(:find_codes_for_autocomplete).and_return(@items)
    end
    
    def do_post
      post :auto_complete_for_core_follow_up_conditions, :follow_up_element => {}
    end
    
    it "should be successful" do
      do_post
      response.should be_success
      assigns[:items].should == @items
    end
    
     it "should assign the items list for the view" do
      do_post
      assigns[:items].should == @items
    end
    
  end
  
end