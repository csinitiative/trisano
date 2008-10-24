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

describe FormsController do
  describe "handling GET /forms" do

    before(:each) do
      mock_user
      @form = mock_model(Form)
      Form.stub!(:find).and_return([@form])
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
  
    it "should find all forms" do
      Form.should_receive(:find).and_return([@form])
      do_get
    end
  
    it "should assign the found forms for the view" do
      do_get
      assigns[:forms].should == [@form]
    end
  end

  describe "handling GET /forms.xml" do

    before(:each) do
      mock_user
      @form = mock_model(Form, :to_xml => "XML")
      Form.stub!(:find).and_return(@form)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all forms" do
      Form.should_receive(:find).and_return([@form])
      do_get
    end
  
    it "should render the found forms as xml" do
      @form.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /forms/1" do

    before(:each) do
      mock_user
      @form = mock_model(Form)
      Form.stub!(:find).and_return(@form)
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
  
    it "should find the form requested" do
      Form.should_receive(:find).with("1").and_return(@form)
      do_get
    end
  
    it "should assign the found form for the view" do
      do_get
      assigns[:form].should equal(@form)
    end
  end

  describe "handling GET /forms/1.xml" do

    before(:each) do
      mock_user
      @form = mock_model(Form, :to_xml => "XML")
      Form.stub!(:find).and_return(@form)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the form requested" do
      Form.should_receive(:find).with("1").and_return(@form)
      do_get
    end
  
    it "should render the found form as xml" do
      @form.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /forms/new" do

    before(:each) do
      mock_user
      @form = mock_model(Form)
      Form.stub!(:new).and_return(@form)
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
  
    it "should create an new form" do
      Form.should_receive(:new).and_return(@form)
      do_get
    end
  
    it "should not save the new form" do
      @form.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new form for the view" do
      do_get
      assigns[:form].should equal(@form)
    end
  end

  describe "handling GET /forms/1/edit" do

    before(:each) do
      mock_user
      @form = mock_model(Form)
      Form.stub!(:find).and_return(@form)
      @form.should_receive(:is_template).and_return(true)
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
  
    it "should find the form requested" do
      Form.should_receive(:find).and_return(@form)
      do_get
    end
  
    it "should assign the found Form for the view" do
      do_get
      assigns[:form].should equal(@form)
    end
  end

  describe "handling POST /forms" do

    before(:each) do
      mock_user
      @form = mock_model(Form, :to_param => "1")
      Form.stub!(:new).and_return(@form)
    end
    
    describe "with successful save" do
  
      def do_post
        @form.should_receive(:save_and_initialize_form_elements).and_return(true)
        post :create, :form => {}
      end
  
      it "should create a new form" do
        Form.should_receive(:new).with({}).and_return(@form)
        do_post
      end

      it "should redirect to the new form" do
        do_post
        response.should redirect_to(form_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @form.should_receive(:save_and_initialize_form_elements).and_return(false)
        @form.errors.should_receive(:each)
        post :create, :form => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /forms/1" do

    before(:each) do
      mock_user
      @form = mock_model(Form, :to_param => "1")
      Form.stub!(:find).and_return(@form)
    end
    
    describe "with successful update" do

      def do_put
        @form.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1", :form => {:disease_ids => [1] }
      end

      it "should find the form requested" do
        Form.should_receive(:find).with("1").and_return(@form)
        do_put
      end

      it "should update the found form" do
        do_put
        assigns(:form).should equal(@form)
      end

      it "should assign the found form for the view" do
        do_put
        assigns(:form).should equal(@form)
      end

      it "should redirect to the form" do
        do_put
        response.should redirect_to(form_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @form.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1", :form => {:disease_ids => [1] }
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /forms/1" do

    before(:each) do
      mock_user
      @form = mock_model(Form, :destroy => true)
      Form.stub!(:find).and_return(@form)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the form requested" do
      Form.should_receive(:find).with("1").and_return(@form)
      do_delete
    end
  
    it "should call destroy on the found form" do
      @form.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the forms list" do
      do_delete
      response.should redirect_to(forms_url)
    end
  end
  
  describe "handling GET /forms/builder/1" do

    before(:each) do
      mock_user
      @form = mock_model(Form)
      Form.stub!(:find).and_return(@form)
      @form.stub!(:structure_valid?).and_return([])
      @form.should_receive(:is_template).and_return(true)
    end
  
    def do_get
      get :builder, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render builder template" do
      do_get
      response.should render_template('builder')
    end
  
    it "should find the form requested" do
      Form.should_receive(:find).and_return(@form)
      do_get
    end
  
    it "should assign the found Form for the view" do
      do_get
      assigns[:form].should equal(@form)
    end
  end
  
  describe "handling GET /forms/rollback/1" do

    before(:each) do
      mock_user
      @form = mock_model(Form)
      Form.stub!(:find).and_return(@form)
      @rolled_back_form = mock_model(Form)
      @form.stub!(:rollback).and_return(@rolled_back_form)
    end
  
    def do_get
      get :rollback, :id => "1"
    end
  
    it "should redirect to the builder" do
      do_get
      response.should redirect_to(builder_path(@rolled_back_form))
    end
  
    it "should find the form requested" do
      Form.should_receive(:find).and_return(@form)
      do_get
    end
  
    it "should assign the rolled back form for the view" do
      do_get
      assigns[:form].should equal(@rolled_back_form)
    end
  end
  
  describe "handling GET /forms/rollback/1 with failed rollback" do

    before(:each) do
      mock_user
      @form = mock_model(Form)
      Form.stub!(:find).and_return(@form)
      @rolled_back_form = mock_model(Form)
      @form.stub!(:rollback).and_return(nil)
    end
  
    def do_get
      get :rollback, :id => "1"
    end
  
    it "should redirect to the builder" do
      do_get
      response.should redirect_to(forms_path)
    end
  
  end
  
  describe "handling POST /forms/order_section_children" do

    before(:each) do
      mock_user
      @reorder_list = ["5", "6", "7"]
      @section = mock_model(SectionElement)
      @form = mock_model(Form)
      reorder_ids = @reorder_list.collect {|id| id.to_i}
      @section.stub!(:reorder_element_children).with(reorder_ids).and_return(true)
      @section.stub!(:form_id).and_return(1)
      FormElement.stub!(:find).and_return(@section)
      Form.stub!(:find).and_return(@form)
    end
  
    def do_post
      post :order_section_children, :id => "3", 'parents-children' => @reorder_list
    end

    it "should be successful" do
      do_post
      response.should be_success
    end
  
    it "should render reorder_section_children template" do
      do_post
      response.should render_template('forms/order_section_children')
    end
  
    it "should find the section requested" do
      FormElement.should_receive(:find).with("3").and_return(@section)
      do_post
    end
    
    it "should call :reorder_element_children on the found section" do
      @section.should_receive(:reorder_element_children)
      do_post
    end
    
    it "should render error template in case of error" do
      @section.stub!(:reorder_element_children).and_return(nil)
      do_post
      response.should render_template('rjs-error')
    end
  
  end
  
  describe "handling POST /forms/publish" do

    before(:each) do
      mock_user
      @form = mock_model(Form, :to_param => "1")
      @published_form = mock_model(Form)
      Form.stub!(:find).and_return(@form)
    end
  
    def do_post
      post :publish, :id => "1"
    end
    
    it "should re-direct to forms index on success" do
      @form.stub!(:publish).and_return(@published_form)
      do_post
      response.should redirect_to(forms_path)
    end
    
    it "should re-render the builder template on failure" do
      @form.stub!(:publish).and_return(nil)
      do_post
      response.should render_template('builder')
    end

  end
  
  describe "handling POST /forms/to_library" do
    
    before(:each) do
      mock_user
      @question_reference = mock_model(QuestionElement)
      @string = mock(String)
      @string.stub!(:humanize).and_return("")
      @question_reference.stub!(:type).and_return(@string)
      FormElement.stub!(:find).and_return(@question_reference)
    end
    
    def do_post
      post :to_library, :group_element_id => "root", :reference_element_id => "1"
    end

    it "should render library elements partial on success" do
      @question_reference.stub!(:add_to_library).and_return(true)
      do_post
      response.should render_template('forms/_library_elements')
    end
    
    it "should render rjs error template on failure" do
      @question_reference.stub!(:add_to_library).and_return(false)
      do_post
      response.should render_template('rjs-error')
    end
  end
  
  describe "handling POST /forms/from_library" do
    
    before(:each) do
      mock_user
      @form = mock_model(Form)
      @form_element = mock_model(FormElement)
      @form_element.stub!(:form_id).and_return("1")
      FormElement.stub!(:find).and_return(@form_element)
      Form.stub!(:find).and_return(@form)
    end
    
    def do_post
      post :from_library, :reference_element_id => "1", :lib_element_id => "2"
    end

    it "should render forms/from_library partial on success with the investigator view branch of the form tree" do
      @ancestors = [nil, InvestigatorViewElementContainer.new]
      @form_element.stub!(:ancestors).and_return(@ancestors)
      @form_element.stub!(:copy_from_library).with("2").and_return(true)
      do_post
      response.should render_template('forms/from_library')
    end
    
    it "should render forms/from_library on success with the core view branch of the form tree" do
      @ancestors = [nil, CoreViewElementContainer.new]
      @form_element.stub!(:ancestors).and_return(@ancestors)
      @form_element.stub!(:copy_from_library).with("2").and_return(true)
      do_post
      response.should render_template('forms/from_library')
    end
    
    it "should render rjs error template on failure" do
      @form_element.stub!(:copy_from_library).with("2").and_return(false)
      do_post
      response.should render_template('rjs-error')
    end
  end
  
  describe "handling GET /forms/library_admin" do
    
    before(:each) do
      mock_user
      @library_elements = []

    end
    
    def do_get
      get :library_admin
    end

    it "should render the correct rjs template on success" do
      FormElement.stub!(:roots).and_return(@library_elements)
      do_get
      response.should render_template('forms/library_admin')
    end
    
    it "should assign the found elements for the view" do
      FormElement.stub!(:roots).and_return(@library_elements)
      do_get
      assigns[:library_elements].should == @library_elements
    end
    
    it "should render rjs error template on failure" do
      FormElement.stub!(:roots).and_raise
      do_get
      response.should render_template('rjs-error')
    end
  end

  describe 'copying a form' do    

    before :each do 
      mock_user
      @form = mock_model(Form)
      @copy = mock_model(Form)
      Form.stub!(:find).and_return(@form)
    end

    it 'should copy form elements w/out reinitializing form_element_base' do
      @form.should_receive(:copy).and_return(@copy)
      @copy.should_receive(:save).and_return(true)      
      post :copy, :id => '1'
    end
  end
  
  describe "handling POST /forms/export" do
    
    describe 'on successful export' do
      
      before :each do 
        mock_user
        @form = mock_model(Form)
        @form.stub!(:name).and_return("Test Form")
        Form.stub!(:find).and_return(@form)
      end
      
      def do_post
        post :export, :id => '1'
      end

      it 'should send export file' do
        @form.should_receive(:export).and_return("test_form.zip")
        @controller.should_receive(:send_file).with(("test_form.zip"))
        do_post
        response.should be_success
      end
      
    end
    
    describe 'on failed export' do
      
      before :each do 
        mock_user
        @form = mock_model(Form)
        @form.stub!(:name).and_return("Test Form")
        Form.stub!(:find).and_return(@form)
      end
      
      def do_post
        post :export, :id => '1'
      end

      it 'should redirect to forms listing' do
        @form.should_receive(:export).and_return(nil)
        @controller.should_not_receive(:send_file).with(("test_form.zip"))
        do_post
        response.should redirect_to(forms_path)
      end
      
    end
  end
  
end
