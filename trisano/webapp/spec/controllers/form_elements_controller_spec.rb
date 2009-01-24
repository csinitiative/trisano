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

describe FormElementsController do
  describe "handling GET /form_elements" do

    before(:each) do
      mock_user
      @form_element = mock_model(FormElement)
      FormElement.stub!(:find).and_return([@form_element])
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
  
    it "should find all form_elements" do
      FormElement.should_receive(:find).with(:all).and_return([@form_element])
      do_get
    end
  
    it "should assign the found form_elements for the view" do
      do_get
      assigns[:form_elements].should == [@form_element]
    end
  end

  describe "handling GET /form_elements.xml" do

    before(:each) do
      mock_user
      @form_element = mock_model(FormElement, :to_xml => "XML")
      FormElement.stub!(:find).and_return(@form_element)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all form_elements" do
      FormElement.should_receive(:find).with(:all).and_return([@form_element])
      do_get
    end
  
    it "should render the found form_elements as xml" do
      @form_element.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /form_elements/1" do

    before(:each) do
      mock_user
      @form_element = mock_model(FormElement)
      FormElement.stub!(:find).and_return(@form_element)
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
  
    it "should find the form_element requested" do
      FormElement.should_receive(:find).with("1").and_return(@form_element)
      do_get
    end
  
    it "should assign the found form_element for the view" do
      do_get
      assigns[:form_element].should equal(@form_element)
    end
  end

  describe "handling GET /form_elements/1.xml" do

    before(:each) do
      mock_user
      @form_element = mock_model(FormElement, :to_xml => "XML")
      FormElement.stub!(:find).and_return(@form_element)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the form_element requested" do
      FormElement.should_receive(:find).with("1").and_return(@form_element)
      do_get
    end
  
    it "should render the found form_element as xml" do
      @form_element.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /form_elements/new" do

    before(:each) do
      mock_user
      @form_element = mock_model(FormElement)
      FormElement.stub!(:new).and_return(@form_element)
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
  
    it "should create an new form_element" do
      FormElement.should_receive(:new).and_return(@form_element)
      do_get
    end
  
    it "should not save the new form_element" do
      @form_element.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new form_element for the view" do
      do_get
      assigns[:form_element].should equal(@form_element)
    end
  end

  describe "handling GET /form_elements/1/edit" do

    before(:each) do
      mock_user
      @form_element = mock_model(FormElement)
      FormElement.stub!(:find).and_return(@form_element)
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
  
    it "should find the form_element requested" do
      FormElement.should_receive(:find).and_return(@form_element)
      do_get
    end
  
    it "should assign the found FormElement for the view" do
      do_get
      assigns[:form_element].should equal(@form_element)
    end
  end

  describe "handling POST /form_elements" do

    before(:each) do
      mock_user
      @form_element = mock_model(FormElement, :to_param => "1")
      FormElement.stub!(:new).and_return(@form_element)
    end
    
    describe "with successful save" do
  
      def do_post
        @form_element.should_receive(:save).and_return(true)
        post :create, :form_element => {}
      end
  
      it "should create a new form_element" do
        FormElement.should_receive(:new).with({}).and_return(@form_element)
        do_post
      end

      it "should redirect to the new form_element" do
        do_post
        response.should redirect_to(form_element_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @form_element.should_receive(:save).and_return(false)
        post :create, :form_element => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /form_elements/1" do

    before(:each) do
      mock_user
      @form_element = mock_model(FormElement, :to_param => "1")
      FormElement.stub!(:find).and_return(@form_element)
    end
    
    describe "with successful update" do

      def do_put
        @form_element.should_receive(:update_and_validate).and_return(true)
        put :update, :id => "1"
      end

      it "should find the form_element requested" do
        FormElement.should_receive(:find).with("1").and_return(@form_element)
        do_put
      end

      it "should update the found form_element" do
        do_put
        assigns(:form_element).should equal(@form_element)
      end

      it "should assign the found form_element for the view" do
        do_put
        assigns(:form_element).should equal(@form_element)
      end

      it "should redirect to the form_element" do
        do_put
        response.should redirect_to(form_element_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @form_element.should_receive(:update_and_validate).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /form_elements/1" do
    
    describe "while handling form hierarchy deletes" do
      before(:each) do
        mock_user
        @form_element = mock_model(FormElement, :destroy => true)
        @form_element.stub!(:form_id).and_return(1)
        @form_element.stub!(:destroy_and_validate).and_return(true)
        FormElement.stub!(:find).and_return(@form_element)
        Form.stub!(:find).and_return(mock_model(Form))
      end
  
      def do_delete
        delete :destroy, :id => "1"
      end

      it "should find the form_element requested" do
        FormElement.should_receive(:find).with("1").and_return(@form_element)
        do_delete
      end
  
      it "should call destroy on the found form_element" do
        @form_element.should_receive(:destroy_and_validate)
        do_delete
      end
  
      it "should render the delete template" do
        do_delete
        response.should render_template('form_elements/destroy')
      end
    end
    
    describe "while handling library admin deletes" do
      before(:each) do
        mock_user
        @form_element = mock_model(FormElement, :destroy => true)
        @form_element.stub!(:form_id).and_return(nil)
        @form_element.stub!(:destroy_and_validate).and_return(true)
        @library_elements = []
        FormElement.stub!(:find).and_return(@form_element)
        FormElement.stub!(:roots).and_return(@library_elements)
      end
  
      def do_delete
        delete :destroy, :id => "1"
      end

      it "should find the form_element requested" do
        FormElement.should_receive(:find).with("1").and_return(@form_element)
        do_delete
      end
  
      it "should call destroy on the found form_element" do
        @form_element.should_receive(:destroy_and_validate)
        do_delete
      end
  
      it "should render the delete template" do
        do_delete
        response.should render_template('form_elements/destroy')
      end
    end
    
  end

  describe 'handling POST /form_elements/update_export_column/1' do
    before(:each) do 
      mock_user
      @form_element = mock(FormElement)
      @form_element.should_receive(:export_column_id=).once.with(nil)
      @form_element.should_receive(:save!).once
      FormElement.stub!(:find).and_return(@form_element)
    end

    def do_post
      post :update_export_column, :id => '1'
    end

    it 'should update the form elements export column' do
      do_post
    end

  end
end
