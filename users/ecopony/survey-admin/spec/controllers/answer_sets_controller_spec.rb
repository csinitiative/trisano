require File.dirname(__FILE__) + '/../spec_helper'

describe AnswerSetsController do
  describe "handling GET /answer_sets" do

    before(:each) do
      @answer_set = mock_model(AnswerSet)
      AnswerSet.stub!(:find).and_return([@answer_set])
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
  
    it "should find all answer_sets" do
      AnswerSet.should_receive(:find).with(:all).and_return([@answer_set])
      do_get
    end
  
    it "should assign the found answer_sets for the view" do
      do_get
      assigns[:answer_sets].should == [@answer_set]
    end
  end

  describe "handling GET /answer_sets.xml" do

    before(:each) do
      @answer_set = mock_model(AnswerSet, :to_xml => "XML")
      AnswerSet.stub!(:find).and_return(@answer_set)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all answer_sets" do
      AnswerSet.should_receive(:find).with(:all).and_return([@answer_set])
      do_get
    end
  
    it "should render the found answer_sets as xml" do
      @answer_set.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /answer_sets/1" do

    before(:each) do
      @answer_set = mock_model(AnswerSet)
      AnswerSet.stub!(:find).and_return(@answer_set)
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
  
    it "should find the answer_set requested" do
      AnswerSet.should_receive(:find).with("1").and_return(@answer_set)
      do_get
    end
  
    it "should assign the found answer_set for the view" do
      do_get
      assigns[:answer_set].should equal(@answer_set)
    end
  end

  describe "handling GET /answer_sets/1.xml" do

    before(:each) do
      @answer_set = mock_model(AnswerSet, :to_xml => "XML")
      AnswerSet.stub!(:find).and_return(@answer_set)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the answer_set requested" do
      AnswerSet.should_receive(:find).with("1").and_return(@answer_set)
      do_get
    end
  
    it "should render the found answer_set as xml" do
      @answer_set.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /answer_sets/new" do

    before(:each) do
      @answer_set = mock_model(AnswerSet)
      AnswerSet.stub!(:new).and_return(@answer_set)
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
  
    it "should create an new answer_set" do
      AnswerSet.should_receive(:new).and_return(@answer_set)
      do_get
    end
  
    it "should not save the new answer_set" do
      @answer_set.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new answer_set for the view" do
      do_get
      assigns[:answer_set].should equal(@answer_set)
    end
  end

  describe "handling GET /answer_sets/1/edit" do

    before(:each) do
      @answer_set = mock_model(AnswerSet)
      AnswerSet.stub!(:find).and_return(@answer_set)
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
  
    it "should find the answer_set requested" do
      AnswerSet.should_receive(:find).and_return(@answer_set)
      do_get
    end
  
    it "should assign the found AnswerSet for the view" do
      do_get
      assigns[:answer_set].should equal(@answer_set)
    end
  end

  describe "handling POST /answer_sets" do

    before(:each) do
      @answer_set = mock_model(AnswerSet, :to_param => "1")
      AnswerSet.stub!(:new).and_return(@answer_set)
    end
    
    describe "with successful save" do
  
      def do_post
        @answer_set.should_receive(:save).and_return(true)
        post :create, :answer_set => {}
      end
  
      it "should create a new answer_set" do
        AnswerSet.should_receive(:new).with({}).and_return(@answer_set)
        do_post
      end

      it "should redirect to the new answer_set" do
        do_post
        response.should redirect_to(answer_set_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @answer_set.should_receive(:save).and_return(false)
        post :create, :answer_set => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /answer_sets/1" do

    before(:each) do
      @answer_set = mock_model(AnswerSet, :to_param => "1")
      AnswerSet.stub!(:find).and_return(@answer_set)
    end
    
    describe "with successful update" do

      def do_put
        @answer_set.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the answer_set requested" do
        AnswerSet.should_receive(:find).with("1").and_return(@answer_set)
        do_put
      end

      it "should update the found answer_set" do
        do_put
        assigns(:answer_set).should equal(@answer_set)
      end

      it "should assign the found answer_set for the view" do
        do_put
        assigns(:answer_set).should equal(@answer_set)
      end

      it "should redirect to the answer_set" do
        do_put
        response.should redirect_to(answer_set_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @answer_set.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /answer_sets/1" do

    before(:each) do
      @answer_set = mock_model(AnswerSet, :destroy => true)
      AnswerSet.stub!(:find).and_return(@answer_set)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the answer_set requested" do
      AnswerSet.should_receive(:find).with("1").and_return(@answer_set)
      do_delete
    end
  
    it "should call destroy on the found answer_set" do
      @answer_set.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the answer_sets list" do
      do_delete
      response.should redirect_to(answer_sets_url)
    end
  end
end