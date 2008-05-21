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
      @question_element = mock_model(QuestionElement)
      @question = mock_model(Question)
      @question.stub!(:is_core_data).and_return(false)
      @question.stub!(:core_data=).and_return(false)
      Question.stub!(:new).and_return(@question)
      @question_element.stub!(:parent_element_id=)
      @question_element.stub!(:question=)
      @question_element.stub!(:question).and_return(@question)
      QuestionElement.stub!(:new).and_return(@question_element)
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
      @question_element = mock_model(QuestionElement, :to_param => "1")
      @question_element.stub!(:form_id).and_return("1")
      QuestionElement.stub!(:new).and_return(@question_element)
    end
    
    describe "with successful save" do
  
      def do_post
        @question_element.should_receive(:save_and_add_to_form).and_return(true)
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
        post :create, :question_element => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /question_elements/1" do

    before(:each) do
      mock_user
      @question_element = mock_model(QuestionElement, :to_param => "1")
      QuestionElement.stub!(:find).and_return(@question_element)
    end
    
    describe "with successful update" do

      def do_put
        @question_element.should_receive(:update_attributes).and_return(true)
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

      it "should redirect to the question_element" do
        do_put
        response.should redirect_to(question_element_url("1"))
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
end