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

describe ValueSetElementsController do
  describe "handling GET /value_set_elements" do

    before(:each) do
      mock_user
      @value_set_element = Factory.build(:value_set_element)
      ValueSetElement.stubs(:find).returns([@value_set_element])
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
  
    it "should find all value_set_elements" do
      ValueSetElement.expects(:find).with(:all).returns([@value_set_element])
      do_get
    end
  
    it "should assign the found value_set_elements for the view" do
      do_get
      assigns[:value_set_elements].should == [@value_set_element]
    end
  end

  describe "handling GET /value_set_elements.xml" do

    before(:each) do
      mock_user
      @value_set_element = Factory.build(:value_set_element)
      ValueSetElement.stubs(:find).returns(@value_set_element)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all value_set_elements" do
      ValueSetElement.expects(:find).with(:all).returns([@value_set_element])
      do_get
    end
  
    it "should render the found value_set_elements as xml" do
      @value_set_element.expects(:to_xml).returns("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /value_set_elements/1" do

    before(:each) do
      mock_user
      @value_set_element = Factory.build(:value_set_element)
      ValueSetElement.stubs(:find).returns(@value_set_element)
    end
  
    def do_get
      get :show, :id => "1"
    end

    it "should return a 405" do
      do_get
      response.response_code.should == 405
    end
  end

  describe "handling GET /value_set_elements/new" do

    before(:each) do
      mock_user
      @question_element = Factory.build(:question_element)
      @value_set_element = Factory.build(:value_set_element)
      ValueSetElement.stubs(:new).returns(@value_set_element)
      @value_set_element.stubs(:parent_element_id=)
      @value_set_element.stubs(:form_id=)
      FormElement.stubs(:find).returns(@question_element)
    end
  
    def do_get
      get :new, :parent_element_id => 5, :form_id => 1
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render new template" do
      do_get
      response.should render_template('new')
    end
  
    it "should create an new value_set_element" do
      ValueSetElement.expects(:new).returns(@value_set_element)
      do_get
    end
  
    it "should not save the new value_set_element" do
      @value_set_element.expects(:save).never
      do_get
    end
  
    it "should assign the new value_set_element for the view" do
      do_get
      assigns[:value_set_element].should equal(@value_set_element)
    end
  end

  describe "handling GET /value_set_elements/1/edit" do

    before(:each) do
      mock_user
      @value_set_element = Factory.build(:value_set_element)
      ValueSetElement.stubs(:find).returns(@value_set_element)
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
  
    it "should find the value_set_element requested" do
      ValueSetElement.expects(:find).returns(@value_set_element)
      do_get
    end
  
    it "should assign the found ValueSetElement for the view" do
      do_get
      assigns[:value_set_element].should equal(@value_set_element)
    end
  end

  describe "handling POST /value_set_elements" do

    before(:each) do
      mock_user
      @value_set_element = Factory.build(:value_set_element)
      @value_set_element.stubs(:form_id).returns(1)
      ValueSetElement.stubs(:new).returns(@value_set_element)
      FormElement.stubs(:find).returns(@section_element)
      FormElement.stubs(:roots).returns([])
    end
    
    describe "with successful save" do
  
      def do_post
        @request.env["HTTP_ACCEPT"] = "application/javascript"
        @value_set_element.expects(:save_and_add_to_form).returns(true)
        Form.stubs(:find).with(1).returns(Factory.build(:form))
        
        post :create, :value_set_element => {}
      end
  
      it "should create a new value_set_element" do
        ValueSetElement.expects(:new).with({}).returns(@value_set_element)
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
        @value_set_element.stubs(:parent_element_id).returns(1)
        @value_set_element.expects(:save_and_add_to_form).returns(false)
        @value_set_element.errors.expects(:each)
        post :create, :value_set_element => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /value_set_elements/1" do

    before(:each) do
      mock_user
      @value_set_element = Factory.create(:value_set_element)
      ValueSetElement.stubs(:find).returns(@value_set_element)
    end
    
    describe "with successful update" do

      def do_put
        @value_set_element.expects(:update_and_validate).returns(true)
        put :update, :id => "1",  :value_set_element => {}
      end

      it "should find the value_set_element requested" do
        ValueSetElement.expects(:find).with("1").returns(@value_set_element)
        do_put
      end

      it "should update the found value_set_element" do
        do_put
        assigns(:value_set_element).should equal(@value_set_element)
      end

      it "should assign the found value_set_element for the view" do
        do_put
        assigns(:value_set_element).should equal(@value_set_element)
      end

      it "should redirect to the value_set_element" do
        do_put
        response.should redirect_to(value_set_element_url(@value_set_element))
      end

    end
    
    describe "with failed update" do

      def do_put
        @value_set_element.expects(:update_and_validate).returns(false)
        put :update, :id => "1", :value_set_element => {}
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /value_set_elements/1" do

    before(:each) do
      mock_user
      @value_set_element = Factory.build(:value_set_element)
      ValueSetElement.stubs(:find).returns(@value_set_element)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the value_set_element requested" do
      ValueSetElement.expects(:find).with("1").returns(@value_set_element)
      do_delete
    end
  
    it "should call destroy on the found value_set_element" do
      @value_set_element.expects(:destroy_and_validate)
      do_delete
    end
  
    it "should redirect to the value_set_elements list" do
      do_delete
      response.should redirect_to(value_set_elements_url)
    end
  end
  
  describe "handling POST /value_set_elements/toggle_value/1 with successful save" do

    before(:each) do
      mock_user
      @value_element = Factory.build(:value_element)
      ValueElement.stubs(:find).returns(@value_element)
      @value_element.stubs(:toggle)
      @value_element.stubs(:save!)
      @value_element.stubs(:form_id).returns(1)
      Form.stubs(:find).with(1).returns(Factory.build(:form))
    end
  
    def do_post
      @request.env["HTTP_ACCEPT"] = "application/javascript"
      post :toggle_value, :value_element_id => "1"
    end

    it "should find the value_set_element requested" do
      ValueElement.expects(:find).with("1").returns(@value_element)
      do_post
    end
    
    it "should render the toggle_value template" do
      do_post
      response.should render_template('toggle_value')
    end

  end
  
  describe "handling POST /value_set_elements/toggle_value/1 with failed save" do

    before(:each) do
      mock_user
      @value_element = Factory.build(:value_element)
      ValueElement.stubs(:find).returns(@value_element)
      @value_element.stubs(:toggle)
      @value_element.stubs(:save!).raises(Exception)
      @value_element.stubs(:form_id).returns(1)
      Form.stubs(:find).with(1).returns(Factory.build(:form))
    end
  
    def do_post
      @request.env["HTTP_ACCEPT"] = "application/javascript"
      post :toggle_value, :value_element_id => "1"
    end
    
    it "should render the toggle_value template" do
      do_post
      response.should render_template('rjs-error')
    end

  end
  
end
