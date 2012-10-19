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

describe QuestionElementsController do
  describe "handling GET /question_elements" do

    before(:each) do
      mock_user
      session[:user_id] = @user.uid
      @question_element = Factory.build(:question_element)
      QuestionElement.stubs(:find).returns([@question_element])
    end

    def do_get
      get :index
    end

    it "should return a 404" do
      do_get
      response.response_code.should == 404
    end
  end

  describe "handling GET /question_elements/1" do

    before(:each) do
      mock_user
      session[:user_id] = @user.uid
      @question_element = Factory.build(:question_element)
      QuestionElement.stubs(:find).returns(@question_element)
    end

    def do_get
      get :show, :id => "1"
    end

    it "should return a 404" do
      do_get
      response.response_code.should == 404
    end
  end

  describe "handling GET /question_elements/new" do

    before(:each) do
      mock_user
      session[:user_id] = @user.uid
      @form = Factory.build(:form)
      @section_element = Factory.build(:section_element)
      @question_element = Factory.build(:question_element)
      @question = Factory.build(:question)
      @question.stubs(:is_core_data).returns(false)
      @question.stubs(:core_data=).returns(false)
      Question.stubs(:new).returns(@question)
      @question_element.stubs(:parent_element_id=)
      @question_element.stubs(:question=)
      @question_element.stubs(:question).returns(@question)
      QuestionElement.stubs(:new).returns(@question_element)
      FormElement.stubs(:find).returns(@section_element)
      @section_element.stubs(:form).returns(@form)
      @form.stubs(:disease_ids).returns([])
    end

    def do_get
      get :new, :form_element_id => 1
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render new template" do
      do_get
      response.should render_template('new')
    end
  
    it "should create an new question_element" do
      QuestionElement.expects(:new).returns(@question_element)
      do_get
    end
  
    it "should not save the new question_element" do
      @question_element.expects(:save).never
      do_get
    end
  
    it "should assign the new question_element for the view" do
      do_get
      assigns[:question_element].should equal(@question_element)
    end
  end

  describe "handling GET /question_elements/1/edit" do

    before(:each) do
      mock_user
      session[:user_id] = @user.uid
      @question_element = Factory.build(:question_element)
      @form = Factory.build(:form)
      
      QuestionElement.stubs(:find).returns(@question_element)
      
      @question_element.stubs(:form).returns(@form)
      @form.stubs(:disease_ids).returns([])
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
  
    it "should find the question_element requested" do
      QuestionElement.expects(:find).returns(@question_element)
      do_get
    end
  
    it "should assign the found QuestionElement for the view" do
      do_get
      assigns[:question_element].should equal(@question_element)
    end
  end

  describe "handling POST /question_elements" do

    before(:each) do
      mock_user
      session[:user_id] = @user.uid
      @form = Factory.build(:form)
      @form.stubs(:disease_ids).returns([])
      @section_element = Factory.build(:section_element)
      @section_element.stubs(:form).returns(@form)
      @question_element = Factory.build(:question_element)
      @question_element.stubs(:form_id).returns(1)
      QuestionElement.stubs(:new).returns(@question_element)
      
      @question_element.stubs(:parent_element_id).returns(1)
      FormElement.stubs(:find).returns(@section_element)
      FormElement.stubs(:roots).returns([])
    end
    
    describe "with successful save" do
  
      def do_post
        @question_element.expects(:save_and_add_to_form).returns(true)
        Form.stubs(:find).with(1).returns(Factory.build(:form))
        post :create, :question_element => {}
      end
  
      it "should create a new question_element" do
        QuestionElement.expects(:new).with({}).returns(@question_element)
        do_post
      end

      it "should render the create view" do
        do_post
        response.should render_template('create')
      end

    end

    describe "with failed save" do

      def do_post
        @question_element.expects(:save_and_add_to_form).returns(false)
        post :create, :question_element => {}
      end

      it "should re-render 'new'" do
        @question_element.stubs(:question=)
        do_post
        response.should render_template('new')
      end

    end
  end

  describe "handling PUT /question_elements/1" do

    before(:each) do
      mock_user
      session[:user_id] = @user.uid
      @question_element = Factory.build(:question_element)
      @form = Factory.build(:form)
      @form.stubs(:disease_ids).returns([])
      @question_element.stubs(:form_id).returns(1)
      @question_element.stubs(:form).returns(@form)
      QuestionElement.stubs(:find).returns(@question_element)
    end

    describe "with successful update" do

      def do_put
        @question_element.expects(:update_and_validate).returns(true)
        Form.stubs(:find).with(1).returns(Factory.build(:form))
        put :update, :id => "1"
      end

      it "should find the question_element requested" do
        QuestionElement.expects(:find).with("1").returns(@question_element)
        do_put
      end

      it "should update the found question_element" do
        do_put
        assigns(:question_element).should equal(@question_element)
      end

      it "should assign the found question_element for the view" do
        do_put
        assigns(:question_element).should equal(@question_element)
      end

      it "should render the update view" do
        do_put
        response.should render_template('update')
      end

    end

    describe "with failed update" do

      def do_put
        @question_element.expects(:update_and_validate).returns(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling POST /question_elements/process_conditional" do

    before(:each) do
      mock_user
      session[:user_id] = @user.uid
      @event = Factory.build(:morbidity_event)
      @follow_up = Factory.build(:follow_up_element)
      @follow_ups = [@follow_up]
      @question_element = Factory.build(:question_element)
      QuestionElement.stubs(:find).returns(@question_element)
      Event.stubs(:find).returns(@event)
    end

    describe "with successful condition processing" do

      def do_post
        post :process_condition, :question_element_id => "1", :response => "Yes", :event_id => "1"
      end

      it "should be successful" do
        @question_element.stubs(:process_condition).returns(@follow_ups)
        do_post
        response.should be_success
      end

      it "should assign the follow up group for the view" do
        @question_element.stubs(:process_condition).returns(@follow_ups)
        do_post
        assigns(:follow_ups).should equal(@follow_ups)
      end

      it "should assign the event for the view to use to build form fields" do
        @question_element.stubs(:process_condition).returns(@follow_ups)
        do_post
        assigns(:event).should equal(@event)
      end

      it "should render the process_condition rjs template" do
        @question_element.stubs(:process_condition).returns(@follow_ups)
        do_post
        response.should render_template('process_condition')
      end

    end

    describe "with unsuccessful condition processing" do
      def do_post
        post :process_condition, :question_element_id => "1", :response => "Yes", :event_id => "1"
      end

      it "should render rjs failure template" do
        @question_element.stubs(:process_condition).raises(Exception)
        do_post
        response.should render_template('rjs-error')
      end

    end

  end

end
