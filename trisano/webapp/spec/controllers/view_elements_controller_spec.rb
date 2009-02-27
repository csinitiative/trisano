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

describe ViewElementsController do
  describe "handling GET /view_elements" do

    before(:each) do
      mock_user
      @view_element = mock_model(ViewElement)
      ViewElement.stub!(:find).and_return([@view_element])
    end
  
    def do_get
      get :index
    end
  
    it "should return a 404" do
      do_get
      response.response_code.should == 404
    end
  end

  describe "handling GET /view_elements/1" do

    before(:each) do
      mock_user
      @view_element = mock_model(ViewElement)
      ViewElement.stub!(:find).and_return(@view_element)
    end
  
    def do_get
      get :show, :id => "1"
    end

    it "should return a 404" do
      do_get
      response.response_code.should == 404
    end
  end

  describe "handling GET /view_elements/new" do

    before(:each) do
      mock_user
      @view_element = mock_model(ViewElement)
      ViewElement.stub!(:new).and_return(@view_element)
      @view_element.stub!(:parent_element_id=)
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
  
    it "should create an new view_element" do
      ViewElement.should_receive(:new).and_return(@view_element)
      do_get
    end
  
    it "should not save the new view_element" do
      @view_element.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new view_element for the view" do
      do_get
      assigns[:view_element].should equal(@view_element)
    end
  end

  describe "handling GET /view_elements/1/edit" do

    before(:each) do
      mock_user
      @view_element = mock_model(ViewElement)
      ViewElement.stub!(:find).and_return(@view_element)
    end
  
    def do_get
      get :edit, :id => "1"
    end

    it "should return a 404" do
      do_get
      response.response_code.should == 404
    end
  end

  describe "handling POST /view_elements" do

    before(:each) do
      mock_user
      @view_element = mock_model(ViewElement, :to_param => "1")
      @view_element.stub!(:form_id).and_return(1)
      ViewElement.stub!(:new).and_return(@view_element)
    end
    
    describe "with successful save" do
  
      def do_post
        @request.env["HTTP_ACCEPT"] = "application/javascript"
        @view_element.should_receive(:save_and_add_to_form).and_return(true)
        Form.stub!(:find).with(1).and_return(mock_model(Form))
        post :create, :view_element => {}
      end
  
      it "should create a new view_element" do
        ViewElement.should_receive(:new).with({}).and_return(@view_element)
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
        @view_element.should_receive(:save_and_add_to_form).and_return(false)
        @view_element.errors.should_receive(:each)
        post :create, :view_element => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /view_elements/1" do

    before(:each) do
      mock_user
      @view_element = mock_model(ViewElement, :to_param => "1")
      ViewElement.stub!(:find).and_return(@view_element)
    end
    
    def do_put
      put :update, :id => "1"
    end

    it "should return a 404" do
      do_put
      response.response_code.should == 404
    end
  end

  describe "handling DELETE /view_elements/1" do

    before(:each) do
      mock_user
      @view_element = mock_model(ViewElement, :destroy_and_validate => true)
      ViewElement.stub!(:find).and_return(@view_element)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the view_element requested" do
      ViewElement.should_receive(:find).with("1").and_return(@view_element)
      do_delete
    end
  
    it "should call destroy on the found view_element" do
      @view_element.should_receive(:destroy_and_validate)
      do_delete
    end
  
    it "should redirect to the view_elements list" do
      do_delete
      response.should redirect_to(view_elements_url)
    end
  end
end
