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

describe QuestionElementsController do
  describe "handling GET /question_elements" do

    before(:each) do
      mock_user
      @question_element = mock_model(QuestionElement)
      QuestionElement.stub!(:find).and_return([@question_element])
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
  
    it "should find all question_elements" do
      QuestionElement.should_receive(:find).with(:all).and_return([@question_element])
      do_get
    end
  
    it "should assign the found question_elements for the view" do
      do_get
      assigns[:question_elements].should == [@question_element]
    end
  end

  describe "handling GET /question_elements.xml" do

    before(:each) do
      mock_user
      @question_element = mock_model(QuestionElement, :to_xml => "XML")
      QuestionElement.stub!(:find).and_return(@question_element)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all question_elements" do
      QuestionElement.should_receive(:find).with(:all).and_return([@question_element])
      do_get
    end
  
    it "should render the found question_elements as xml" do
      @question_element.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /question_elements/1" do

    before(:each) do
      mock_user
      @question_element = mock_model(QuestionElement)
      QuestionElement.stub!(:find).and_return(@question_element)
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
  
    it "should find the question_element requested" do
      QuestionElement.should_receive(:find).with("1").and_return(@question_element)
      do_get
    end
  
    it "should assign the found question_element for the view" do
      do_get
      assigns[:question_element].should equal(@question_element)
    end
  end

  describe "handling GET /question_elements/1.xml" do

    before(:each) do
      mock_user
      @question_element = mock_model(QuestionElement, :to_xml => "XML")
      QuestionElement.stub!(:find).and_return(@question_element)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the question_element requested" do
      QuestionElement.should_receive(:find).with("1").and_return(@question_element)
      do_get
    end
  
    it "should render the found question_element as xml" do
      @question_element.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /question_elements/new" do

    before(:each) do
      mock_user
      @section_element = mock_model(SectionElement)
      @question_element = mock_model(QuestionElement)
      @question = mock_model(Question)
      @question.stub!(:is_core_data).and_return(false)
      @question.stub!(:core_data=).and_return(false)
      Question.stub!(:new).and_return(@question)
      @question_element.stub!(:parent_element_id=)
      @question_element.stub!(:question=)
      @question_element.stub!(:question).and_return(@question)
      QuestionElement.stub!(:new).and_return(@question_element)
      FormElement.stub!(:find).and_return(@section_element)
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
      QuestionElement.should_receive(:new).and_return(@question_element)
      do_get
    end
  
    it "should not save the new question_element" do
      @question_element.should_not_receive(:save)
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
      @question_element = mock_model(QuestionElement)
      QuestionElement.stub!(:find).and_return(@question_element)
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
      QuestionElement.should_receive(:find).and_return(@question_element)
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
      @section_element = mock_model(SectionElement)
      @question_element = mock_model(QuestionElement, :to_param => "1")
      @question_element.stub!(:form_id).and_return(1)
      QuestionElement.stub!(:new).and_return(@question_element)
      
      @question_element.stub!(:parent_element_id).and_return(1)
      FormElement.stub!(:find).and_return(@section_element)
      FormElement.stub!(:roots).and_return([])
    end
    
    describe "with successful save" do
  
      def do_post
        @question_element.should_receive(:save_and_add_to_form).and_return(true)
        Form.stub!(:find).with(1).and_return(mock_model(Form))
        post :create, :question_element => {}
      end
  
      it "should create a new question_element" do
        QuestionElement.should_receive(:new).with({}).and_return(@question_element)
        do_post
      end

      it "should render the create view" do
        do_post
        response.should render_template('create')
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @question_element.should_receive(:save_and_add_to_form).and_return(false)
        @question_element.errors.should_receive(:each)
        post :create, :question_element => {}
      end
  
      it "should re-render 'new'" do
        @question_element.stub!(:question=)
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /question_elements/1" do

    before(:each) do
      mock_user
      @question_element = mock_model(QuestionElement, :to_param => "1")
      @question_element.stub!(:form_id).and_return(1)
      QuestionElement.stub!(:find).and_return(@question_element)
    end
    
    describe "with successful update" do

      def do_put
        @question_element.should_receive(:update_attributes).and_return(true)
        Form.stub!(:find).with(1).and_return(mock_model(Form))
        put :update, :id => "1"
      end

      it "should find the question_element requested" do
        QuestionElement.should_receive(:find).with("1").and_return(@question_element)
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
        @question_element.should_receive(:update_attributes).and_return(false)
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
      @event = mock_model(Event)
      @follow_up = mock_model(FollowUpElement)
      @question_element = mock_model(QuestionElement, :to_param => "1")
      QuestionElement.stub!(:find).and_return(@question_element)
      Event.stub!(:find).and_return(@event)
    end
  
    describe "with successful condition processing" do
    
      def do_post
        post :process_condition, :question_element_id => "1", :response => "Yes", :event_id => "1"
      end
      
      it "should be successful" do
        @question_element.stub!(:process_condition).and_return(@follow_up)
        do_post
        response.should be_success
      end
      
      it "should assign the follow up group for the view" do
        @question_element.stub!(:process_condition).and_return(@follow_up)
        do_post
        assigns(:follow_up).should equal(@follow_up)
      end
    
      it "should assign the event for the view to use to build form fields" do
        @question_element.stub!(:process_condition).and_return(@follow_up)
        do_post
        assigns(:event).should equal(@event)
      end
      
      it "should render the process_condition rjs template" do
        @question_element.stub!(:process_condition).and_return(@follow_up)
        do_post
        response.should render_template('process_condition')
      end
    
    end
    
    describe "with unsuccessful condition processing" do
      def do_post
        post :process_condition, :question_element_id => "1", :response => "Yes", :event_id => "1"
      end
    
      it "should render rjs failure template" do
        @question_element.stub!(:process_condition).and_raise(Exception)
        do_post
        response.should render_template('rjs-error')
      end
    
    end

  end
  
end