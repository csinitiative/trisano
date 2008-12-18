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

describe CoreFieldElementsController do
  describe "handling GET /core_field_elements" do

    before(:each) do
      mock_user
      @core_field_element = mock_model(CoreFieldElement)
      CoreFieldElement.stub!(:find).and_return([@core_field_element])
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
  
    it "should find all core_field_elements" do
      CoreFieldElement.should_receive(:find).with(:all).and_return([@core_field_element])
      do_get
    end
  
    it "should assign the found core_field_elements for the view" do
      do_get
      assigns[:core_field_elements].should == [@core_field_element]
    end
  end

  describe "handling GET /core_field_elements.xml" do

    before(:each) do
      mock_user
      @core_field_element = mock_model(CoreFieldElement, :to_xml => "XML")
      CoreFieldElement.stub!(:find).and_return(@core_field_element)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all core_field_elements" do
      CoreFieldElement.should_receive(:find).with(:all).and_return([@core_field_element])
      do_get
    end
  
    it "should render the found core_field_elements as xml" do
      @core_field_element.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /core_field_elements/1" do

    before(:each) do
      mock_user
      @core_field_element = mock_model(CoreFieldElement)
      CoreFieldElement.stub!(:find).and_return(@core_field_element)
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
  
    it "should find the core_field_element requested" do
      CoreFieldElement.should_receive(:find).with("1").and_return(@core_field_element)
      do_get
    end
  
    it "should assign the found core_field_element for the view" do
      do_get
      assigns[:core_field_element].should equal(@core_field_element)
    end
  end

  describe "handling GET /core_field_elements/1.xml" do

    before(:each) do
      mock_user
      @core_field_element = mock_model(CoreFieldElement, :to_xml => "XML")
      CoreFieldElement.stub!(:find).and_return(@core_field_element)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the core_field_element requested" do
      CoreFieldElement.should_receive(:find).with("1").and_return(@core_field_element)
      do_get
    end
  
    it "should render the found core_field_element as xml" do
      @core_field_element.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /core_field_elements/new" do

    before(:each) do
      mock_user
      @core_field_element = mock_model(CoreFieldElement)
      CoreFieldElement.stub!(:new).and_return(@core_field_element)
      @core_field_element.stub!(:available_core_fields).and_return([])
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
  
    it "should create an new core_field_element" do
      CoreFieldElement.should_receive(:new).and_return(@core_field_element)
      do_get
    end
  
    it "should not save the new core_field_element" do
      @core_field_element.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new core_field_element for the view" do
      do_get
      assigns[:core_field_element].should equal(@core_field_element)
    end
  end

  describe "handling GET /core_field_elements/1/edit" do

    before(:each) do
      mock_user
      @core_field_element = mock_model(CoreFieldElement)
      CoreFieldElement.stub!(:find).and_return(@core_field_element)
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
  
    it "should find the core_field_element requested" do
      CoreFieldElement.should_receive(:find).and_return(@core_field_element)
      do_get
    end
  
    it "should assign the found CoreFieldElement for the field" do
      do_get
      assigns[:core_field_element].should equal(@core_field_element)
    end
  end

  describe "handling POST /core_field_elements" do

    before(:each) do
      mock_user
      @core_field_element = mock_model(CoreFieldElement, :to_param => "1")
      @core_field_element.stub!(:form_id).and_return(1)
      CoreFieldElement.stub!(:new).and_return(@core_field_element)
    end
    
    describe "with successful save" do
  
      def do_post
        @request.env["HTTP_ACCEPT"] = "application/javascript"
        @core_field_element.should_receive(:save_and_add_to_form).and_return(true)
        Form.stub!(:find).with(1).and_return(mock_model(Form))
        post :create, :core_field_element => {}
      end
  
      it "should create a new core_field_element" do
        CoreFieldElement.should_receive(:new).with({}).and_return(@core_field_element)
        do_post
      end

      it "should redirect to the new core_field_element" do
        do_post
        response.should render_template('create')
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @request.env["HTTP_ACCEPT"] = "application/javascript"
        @core_field_element.should_receive(:save_and_add_to_form).and_return(false)
        @core_field_element.stub!(:available_core_fields).and_return([])
        @core_field_element.errors.should_receive(:each)
        post :create, :core_field_element => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /core_field_elements/1" do

    before(:each) do
      mock_user
      @core_field_element = mock_model(CoreFieldElement, :to_param => "1")
      CoreFieldElement.stub!(:find).and_return(@core_field_element)
    end
    
    describe "with successful update" do

      def do_put
        @core_field_element.should_receive(:update_and_validate).and_return(true)
        put :update, :id => "1"
      end

      it "should find the core_field_element requested" do
        CoreFieldElement.should_receive(:find).with("1").and_return(@core_field_element)
        do_put
      end

      it "should update the found core_field_element" do
        do_put
        assigns(:core_field_element).should equal(@core_field_element)
      end

      it "should assign the found core_field_element for the view" do
        do_put
        assigns(:core_field_element).should equal(@core_field_element)
      end

      it "should redirect to the core_field_element" do
        do_put
        response.should redirect_to(core_field_element_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @core_field_element.should_receive(:update_and_validate).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /core_field_elements/1" do

    before(:each) do
      mock_user
      @core_field_element = mock_model(CoreFieldElement, :destroy_and_validate => true)
      CoreFieldElement.stub!(:find).and_return(@core_field_element)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the core_field_element requested" do
      CoreFieldElement.should_receive(:find).with("1").and_return(@core_field_element)
      do_delete
    end
  
    it "should call destroy on the found core_field_element" do
      @core_field_element.should_receive(:destroy_and_validate)
      do_delete
    end
  
    it "should redirect to the core_field_elements list" do
      do_delete
      response.should redirect_to(core_field_elements_url)
    end
  end
end