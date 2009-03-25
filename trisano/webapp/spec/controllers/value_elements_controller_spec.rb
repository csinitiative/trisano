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

describe ValueElementsController do

  before(:each) do
    mock_user
  end

  describe "handling GET /value_elements" do

    def do_get
      get :index
    end

    it "should return a 405" do
      do_get
      response.response_code.should == 405
    end
    
  end

  describe "handling GET /value_elements/1" do

    def do_get
      get :show, :id => "1"
    end

    it "should return a 405" do
      do_get
      response.response_code.should == 405
    end
    
  end

  describe "handling GET /value_elements/new" do

    before(:each) do
      mock_user
      @value_element = mock_model(ValueElement)
      ValueElement.stub!(:new).and_return(@value_element)
      @value_element.stub!(:parent_element_id=)
    end

    def do_get
      get :new, :parent_element_id => 5
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render new template" do
      do_get
      response.should render_template('new')
    end

    it "should create an new value_element" do
      ValueElement.should_receive(:new).and_return(@value_element)
      do_get
    end

    it "should not save the new value_element" do
      @value_element.should_not_receive(:save)
      do_get
    end

    it "should assign the new value_element for the view" do
      do_get
      assigns[:value_element].should equal(@value_element)
    end
  end

  describe "handling GET /value_elements/1/edit" do

    before(:each) do
      mock_user
      @value_element = mock_model(ValueElement)
      ValueElement.stub!(:find).and_return(@value_element)
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

    it "should find the value_element requested" do
      ValueElement.should_receive(:find).and_return(@value_element)
      do_get
    end

    it "should assign the found ValueElement for the view" do
      do_get
      assigns[:value_element].should equal(@value_element)
    end
  end

  describe "handling POST /value_elements" do

    before(:each) do
      mock_user
      @value_element = mock_model(ValueElement, :to_param => "1")
      @value_element.stub!(:form_id).and_return(1)
      ValueElement.stub!(:new).and_return(@value_element)
      FormElement.stub!(:find).and_return(@section_element)
    end

    describe "with successful save" do

      def do_post
        @request.env["HTTP_ACCEPT"] = "application/javascript"
        @value_element.should_receive(:save_and_add_to_form).and_return(true)
        Form.stub!(:find).with(1).and_return(mock_model(Form))

        post :create, :value_element => {}
      end

      it "should create a new value_element" do
        ValueElement.should_receive(:new).with({}).and_return(@value_element)
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
        @value_element.stub!(:parent_element_id).and_return(1)
        @value_element.should_receive(:save_and_add_to_form).and_return(false)
        @value_element.errors.should_receive(:each)
        post :create, :value_element => {}
      end

      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end

    end
  end

  describe "handling PUT /value_elements/1" do

    before(:each) do
      mock_user
      @value_element = mock_model(ValueElement, :to_param => "1")
      @value_element.stub!(:form_id).and_return(1)
      Form.stub!(:find).and_return(mock_model(Form))
      ValueElement.stub!(:find).and_return(@value_element)
    end

    describe "with successful update" do

      def do_put
        @value_element.should_receive(:update_and_validate).and_return(true)
        put :update, :id => "1",  :value_element => {}
      end

      it "should find the value_element requested" do
        ValueElement.should_receive(:find).with("1").and_return(@value_element)
        do_put
      end

      it "should update the found value_element" do
        do_put
        assigns(:value_element).should equal(@value_element)
      end

      it "should assign the found value_element for the view" do
        do_put
        assigns(:value_element).should equal(@value_element)
      end

      it "should redirect to the value_element" do
        do_put
        response.should render_template('update')
      end

    end

    describe "with failed update" do

      def do_put
        @value_element.should_receive(:update_and_validate).and_return(false)
        put :update, :id => "1", :value_element => {}
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /value_elements/1" do

    def do_delete
      delete :destroy, :id => "1"
    end

    it "should return a 405" do
      do_delete
      response.response_code.should == 405
    end
  end

end
