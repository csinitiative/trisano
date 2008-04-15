require File.dirname(__FILE__) + '/../spec_helper'

describe AnswersController do
  describe "handling GET /answers" do

    before(:each) do
      @answer = mock_model(Answer)
      Answer.stub!(:find).and_return([@answer])
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
  
    it "should find all answers" do
      Answer.should_receive(:find).with(:all).and_return([@answer])
      do_get
    end
  
    it "should assign the found answers for the view" do
      do_get
      assigns[:answers].should == [@answer]
    end
  end

  describe "handling GET /answers.xml" do

    before(:each) do
      @answer = mock_model(Answer, :to_xml => "XML")
      Answer.stub!(:find).and_return(@answer)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all answers" do
      Answer.should_receive(:find).with(:all).and_return([@answer])
      do_get
    end
  
    it "should render the found answers as xml" do
      @answer.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /answers/1" do

    before(:each) do
      @answer = mock_model(Answer)
      Answer.stub!(:find).and_return(@answer)
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
  
    it "should find the answer requested" do
      Answer.should_receive(:find).with("1").and_return(@answer)
      do_get
    end
  
    it "should assign the found answer for the view" do
      do_get
      assigns[:answer].should equal(@answer)
    end
  end

  describe "handling GET /answers/1.xml" do

    before(:each) do
      @answer = mock_model(Answer, :to_xml => "XML")
      Answer.stub!(:find).and_return(@answer)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the answer requested" do
      Answer.should_receive(:find).with("1").and_return(@answer)
      do_get
    end
  
    it "should render the found answer as xml" do
      @answer.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /answers/new" do

    before(:each) do
      @answer = mock_model(Answer)
      Answer.stub!(:new).and_return(@answer)
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
  
    it "should create an new answer" do
      Answer.should_receive(:new).and_return(@answer)
      do_get
    end
  
    it "should not save the new answer" do
      @answer.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new answer for the view" do
      do_get
      assigns[:answer].should equal(@answer)
    end
  end

  describe "handling GET /answers/1/edit" do

    before(:each) do
      @answer = mock_model(Answer)
      Answer.stub!(:find).and_return(@answer)
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
  
    it "should find the answer requested" do
      Answer.should_receive(:find).and_return(@answer)
      do_get
    end
  
    it "should assign the found Answer for the view" do
      do_get
      assigns[:answer].should equal(@answer)
    end
  end

  describe "handling POST /answers" do

    before(:each) do
      @answer = mock_model(Answer, :to_param => "1")
      Answer.stub!(:new).and_return(@answer)
    end
    
    describe "with successful save" do
  
      def do_post
        @answer.should_receive(:save).and_return(true)
        post :create, :answer => {}
      end
  
      it "should create a new answer" do
        Answer.should_receive(:new).with({}).and_return(@answer)
        do_post
      end

      it "should redirect to the new answer" do
        do_post
        response.should redirect_to(answer_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @answer.should_receive(:save).and_return(false)
        post :create, :answer => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /answers/1" do

    before(:each) do
      @answer = mock_model(Answer, :to_param => "1")
      Answer.stub!(:find).and_return(@answer)
    end
    
    describe "with successful update" do

      def do_put
        @answer.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the answer requested" do
        Answer.should_receive(:find).with("1").and_return(@answer)
        do_put
      end

      it "should update the found answer" do
        do_put
        assigns(:answer).should equal(@answer)
      end

      it "should assign the found answer for the view" do
        do_put
        assigns(:answer).should equal(@answer)
      end

      it "should redirect to the answer" do
        do_put
        response.should redirect_to(answer_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @answer.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /answers/1" do

    before(:each) do
      @answer = mock_model(Answer, :destroy => true)
      Answer.stub!(:find).and_return(@answer)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the answer requested" do
      Answer.should_receive(:find).with("1").and_return(@answer)
      do_delete
    end
  
    it "should call destroy on the found answer" do
      @answer.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the answers list" do
      do_delete
      response.should redirect_to(answers_url)
    end
  end
end