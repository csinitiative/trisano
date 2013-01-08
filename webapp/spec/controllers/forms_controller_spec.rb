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

describe FormsController do
  describe "handling GET /forms" do

    before(:each) do
      mock_user
      @form = Factory.build(:form)
      Form.stubs(:find).returns([@form])
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
      Form.expects(:find).returns([@form])
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
      @form = Factory.build(:form)
      Form.stubs(:find).returns(@form)
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
      Form.expects(:find).returns([@form])
      do_get
    end

    it "should render the found forms as xml" do
      @form.expects(:to_xml).returns("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /forms/1" do

    before(:each) do
      mock_user
      @form = Factory.build(:form)
      @form.stubs(:structure_valid?).returns(true)
      @form.stubs(:is_template).returns(true)
      Form.stubs(:find).returns(@form)
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
      Form.expects(:find).with("1").returns(@form)
      do_get
    end

    it "should assign the found form for the view" do
      do_get
      assigns[:form].should equal(@form)
    end
  end

  describe "handling GET /forms/new" do

    before(:each) do
      mock_user
      @form = Factory.build(:form)
      Form.stubs(:new).returns(@form)
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
      Form.expects(:new).returns(@form)
      do_get
    end

    it "should not save the new form" do
      @form.expects(:save).never
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
      @form = Factory.build(:form)
      @form.save!
      Form.stubs(:find).returns(@form)
      @form.expects(:is_template).returns(true)
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
      Form.expects(:find).returns(@form)
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
      @form = Factory.build(:form)
      @form.save!
      Form.stubs(:new).returns(@form)
    end

    describe "with successful save" do

      def do_post
        @form.expects(:save_and_initialize_form_elements).returns(true)
        post :create, :form => {}
      end

      it "should create a new form" do
        Form.expects(:new).with({}).returns(@form)
        do_post
      end

      it "should redirect to the new form" do
        do_post
        response.should redirect_to(form_url(@form.id))
      end

    end

    describe "with failed save" do

      def do_post
        @form.expects(:save_and_initialize_form_elements).returns(false)
        @form.errors.expects(:each)
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
      @form = Factory.build(:form)
      @form.save!
      Form.stubs(:find).returns(@form)
    end

    describe "with successful update" do

      def do_put
        @form.expects(:update_attributes).returns(true)
        put :update, :id => "1", :form => {:disease_ids => [1] }
      end

      it "should find the form requested" do
        Form.expects(:find).with("1").returns(@form)
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
        response.should redirect_to(form_url(@form.id))
      end

    end

    describe "with failed update" do

      def do_put
        @form.expects(:update_attributes).returns(false)
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
      @form = Factory.build(:form)
      Form.stubs(:find).returns(@form)
    end

    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the form requested" do
      Form.expects(:find).with("1").returns(@form)
      do_delete
    end

    it "should call destroy on the found form" do
      @form.expects(:destroy)
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
      @form = Factory.build(:form)
      Form.stubs(:find).returns(@form)
      @form.stubs(:structure_valid?).returns([])
      @form.expects(:is_template).returns(true)
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
      Form.expects(:find).returns(@form)
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
      @form = Factory.build(:form)
      Form.stubs(:find).returns(@form)
      @rolled_back_form = Factory.build(:form)
      @form.stubs(:rollback).returns(@rolled_back_form)
    end

    def do_get
      get :rollback, :id => "1"
    end

    it "should redirect to the builder" do
      do_get
      response.should redirect_to(builder_path(@rolled_back_form))
    end

    it "should find the form requested" do
      Form.expects(:find).returns(@form)
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
      @form = Factory.build(:form)
      Form.stubs(:find).returns(@form)
      @rolled_back_form = Factory.build(:form)
      @form.stubs(:rollback).returns(nil)
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
      @section = Factory.build(:section_element)
      @form = Factory.build(:form)
      reorder_ids = @reorder_list.collect {|id| id.to_i}
      @section.stubs(:reorder_element_children).with(reorder_ids).returns(true)
      @section.stubs(:form_id).returns(1)
      FormElement.stubs(:find).returns(@section)
      Form.stubs(:find).returns(@form)
    end

    def do_post
      post :order_section_children, :id => "3", 'question' => @reorder_list
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
      FormElement.expects(:find).with("3").returns(@section)
      do_post
    end

    it "should call :reorder_element_children on the found section" do
      @section.expects(:reorder_element_children)
      do_post
    end

    it "should render error template in case of error" do
      @section.stubs(:reorder_element_children).returns(nil)
      do_post
      response.should render_template('rjs-error')
    end

  end

  describe "handling POST /forms/publish" do

    before(:each) do
      mock_user
      @form = Factory.build(:form)
      @published_form = Factory.build(:form)
      Form.stubs(:find).returns(@form)
    end

    def do_post
      post :publish, :id => "1"
    end

    it "should re-direct to forms index on success" do
      @form.stubs(:publish).returns(@published_form)
      do_post
      response.should redirect_to(forms_path)
    end

    it "should re-render the builder template on failure" do
      @form.stubs(:publish).returns(nil)
      do_post
      response.should render_template('builder')
    end

  end

  describe "handling POST /forms/to_library" do

    before(:each) do
      mock_user
      @question_reference = Factory.build(:question_element)
      @string = mock('String')
      @string.stubs(:humanize).returns("")
      @question_reference.stubs(:type).returns(@string)
      FormElement.stubs(:find).returns(@question_reference)
    end

    def do_post
      post :to_library, :group_element_id => "root", :reference_element_id => "1"
    end

    it "should render library elements partial on success" do
      @question_reference.stubs(:add_to_library).returns(true)
      do_post
      response.should render_template('forms/_library_elements')
    end

    it "should render rjs error template on failure" do
      @question_reference.stubs(:add_to_library).returns(false)
      do_post
      response.should render_template('rjs-error')
    end
  end

  describe "handling POST /forms/from_library" do

    before(:each) do
      mock_user
      @form = Factory.build(:form)
      @form_element = Factory.build(:form_element)
      @form_element.stubs(:form_id).returns("1")
      @form_element.stubs(:can_copy_to?).returns(true)
      @lib_element = Factory.build(:question_element)
      @lib_element.stubs(:compare_short_names).returns([])
      FormElement.stubs(:find).with("1").returns(@form_element)
      FormElement.stubs(:find).with("2").returns(@lib_element)
      Form.stubs(:find).returns(@form)
      @expected_params =  {
        'reference_element_id' => '1',
        'lib_element_id' => '2',
        'action' => 'from_library',
        'controller' => 'forms' }
    end

    def do_post
      post :from_library, :reference_element_id => '1', :lib_element_id => '2'
    end

    it "should render forms/from_library partial on success with the investigator view branch of the form tree" do
      @ancestors = [nil, InvestigatorViewElementContainer.new]
      @form_element.stubs(:ancestors).returns(@ancestors)
      @form_element.stubs(:copy_from_library).with(@lib_element, @expected_params).returns(true)
      do_post
      response.should render_template('forms/from_library')
    end

    it "should render forms/from_library on success with the core view branch of the form tree" do
      @ancestors = [nil, CoreViewElementContainer.new]
      @form_element.stubs(:ancestors).returns(@ancestors)
      @form_element.stubs(:copy_from_library).with(@lib_element, @expected_params).returns(true)
      do_post
      response.should render_template('forms/from_library')
    end

    it "should render rjs error template on invalid form structure" do
      @form_element.stubs(:copy_from_library).with(@lib_element, @expected_params).raises(FormElement::InvalidFormStructure)
      do_post
      response.should render_template('rjs-error')
    end

    it "should render rjs error template on illegal copy operation" do
      @form_element.stubs(:copy_from_library).with(@lib_element, @expected_params).raises(FormElement::IllegalCopyOperation)
      do_post
      response.should render_template('rjs-error')
    end

    it "should render rjs error template on record invalid" do
      @form_element.stubs(:copy_from_library).with(@lib_element, @expected_params).raises(ActiveRecord::RecordInvalid, @lib_element)
      do_post
      response.should render_template('rjs-error')
    end

    it "should fail outright on other runtime exceptions" do
      @form_element.stubs(:copy_from_library).with(@lib_element, @expected_params).raises
      lambda { do_post }.should raise_error
    end

    it "should render fix library copy template on short name collision" do
      question = Factory.build(:question)
      question.stubs(:collision).returns("t")
      @lib_element.stubs(:compare_short_names).returns([question])
      do_post
      response.should render_template('forms/fix_library_copy')
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
      FormElement.stubs(:library_roots).returns(@library_elements)
      do_get
      response.should render_template('forms/library_admin')
    end

    it "should assign the found elements for the view" do
      FormElement.stubs(:library_roots).returns(@library_elements)
      do_get
      assigns[:library_elements].should == @library_elements
    end

    it "should render rjs error template on failure" do
      FormElement.stubs(:library_roots).raises
      do_get
      response.should render_template('rjs-error')
    end
  end

  describe 'copying a form' do

    before :each do
      mock_user
      @form = Factory.build(:form)
      @form.save!
      @copy = Factory.build(:form)
      @copy.save!
      Form.stubs(:find).returns(@form)
    end

    it 'should copy form elements w/out reinitializing form_element_base' do
      @form.expects(:copy).returns(@copy)
      @copy.expects(:save).returns(true)
      post :copy, :id => @copy.id
    end
  end

  describe "handling POST /forms/export" do

    describe 'on successful export' do

      before :each do
        mock_user
        @form = Factory.build(:form)
        @form.stubs(:name).returns("Test Form")
        Form.stubs(:find).returns(@form)
      end

      def do_post
        post :export, :id => '1'
      end

      it 'should send export file' do
        @form.expects(:export).returns("test_form.zip")
        @controller.expects(:send_file).with("test_form.zip")
        do_post
        response.should be_success
      end

    end

    describe 'on failed export' do

      before :each do
        mock_user
        @form = Factory.build(:form)
        @form.stubs(:name).returns("Test Form")
        Form.stubs(:find).returns(@form)
      end

      def do_post
        post :export, :id => '1'
      end

      it 'should redirect to forms listing' do
        @form.expects(:export).returns(nil)
        @form.errors.expects(:empty?).returns(false)
        @form.errors.expects(:[]).returns("error message")
        @controller.expects(:send_file).with(("test_form.zip")).never
        do_post
        response.should redirect_to(forms_path)
      end

    end
  end

  describe "handling POST /forms/import" do

    describe 'when lacking upload file' do

      before :each do
        mock_user
      end

      def do_post
        post :import, :form => {:import => ""}
      end

      it 'should redirect to forms path' do
        do_post
        response.should redirect_to(forms_path)
      end

    end

    describe 'on successful import' do

      before :each do
        mock_user
        @form = Factory.build(:form)
        @form.save!
        @upload_file = mock('ActionController::UploadedStringIO')
      end

      def do_post
        post :import, :form => {:import => @upload_file}
      end

      it 'should be successful' do
        Form.expects(:import).returns(@form)
        do_post
        response.should redirect_to(form_url(@form.id))
      end

    end

    describe 'on failed import' do

      before :each do
        mock_user
        @form = Factory.build(:form)
        @upload_file = mock('ActionController::UploadedStringIO')
      end

      def do_post
        post :import, :form => {:import => @upload_file}
      end

      it 'should redirect to forms listing' do
        Form.expects(:import).returns(nil)
        do_post
        response.should redirect_to(forms_path)
      end

    end
  end

  describe "handling POST /forms/push" do

    describe 'on successful push' do

      before :each do
        mock_user
        @form = Factory.build(:form)
        @form.stubs(:name).returns("Test Form")
        @form.stubs(:push).returns(1)
        Form.stubs(:find).returns(@form)
      end

      def do_post
        post :push, :id => '1'
      end

      it 'should redirect to forms listing' do
        do_post
        response.should redirect_to(forms_path)
      end

      it 'should populate the flash notice' do
        do_post
        flash[:notice].should eql("Form was successfully pushed to events")
      end

    end

    describe 'on failed push' do

      before :each do
        mock_user
        @form = Factory.build(:form)
        @form.stubs(:name).returns("Test Form")
        @form.stubs(:push).returns(nil)
        Form.stubs(:find).returns(@form)
      end

      def do_post
        post :push, :id => '1'
      end

      it 'should redirect to forms listing' do
        do_post
        response.should redirect_to(forms_path)
      end

      it 'should populate the flash error' do
        do_post
        flash[:error].should eql("Unable to push the form")
      end

    end
  end

    describe "handling POST /forms/deactivate" do

    describe 'on successful deactivate' do

      before :each do
        mock_user
        @form = Factory.build(:form)
        @form.stubs(:name).returns("Test Form")
        @form.stubs(:deactivate).returns(1)
        Form.stubs(:find).returns(@form)
      end

      def do_post
        post :deactivate, :id => '1'
      end

      it 'should redirect to forms listing' do
        do_post
        response.should redirect_to(forms_path)
      end

      it 'should populate the flash notice' do
        do_post
        flash[:notice].should eql("Form was successfully deactivated")
      end

    end

    describe 'on failed deactivate' do

      before :each do
        mock_user
        @form = Factory.build(:form)
        @form.stubs(:name).returns("Test Form")
        @form.stubs(:deactivate).returns(nil)
        Form.stubs(:find).returns(@form)
      end

      def do_post
        post :deactivate, :id => '1'
      end

      it 'should redirect to forms listing' do
        do_post
        response.should redirect_to(forms_path)
      end

      it 'should populate the flash error' do
        do_post
        flash[:error].should eql("Unable to deactivate the form")
      end

    end
  end

end
