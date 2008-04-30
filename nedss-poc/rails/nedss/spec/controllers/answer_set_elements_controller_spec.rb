require File.dirname(__FILE__) + '/../spec_helper'

describe AnswerSetElementsController do
  describe "handling GET /answer_set_elements" do

    before(:each) do
      mock_user
      @answer_set_element = mock_model(AnswerSetElement)
      AnswerSetElement.stub!(:find).and_return([@answer_set_element])
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
  
    it "should find all answer_set_elements" do
      AnswerSetElement.should_receive(:find).with(:all).and_return([@answer_set_element])
      do_get
    end
  
    it "should assign the found answer_set_elements for the view" do
      do_get
      assigns[:answer_set_elements].should == [@answer_set_element]
    end
  end

  describe "handling GET /answer_set_elements.xml" do

    before(:each) do
      mock_user
      @answer_set_element = mock_model(AnswerSetElement, :to_xml => "XML")
      AnswerSetElement.stub!(:find).and_return(@answer_set_element)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all answer_set_elements" do
      AnswerSetElement.should_receive(:find).with(:all).and_return([@answer_set_element])
      do_get
    end
  
    it "should render the found answer_set_elements as xml" do
      @answer_set_element.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /answer_set_elements/1" do

    before(:each) do
      mock_user
      @answer_set_element = mock_model(AnswerSetElement)
      AnswerSetElement.stub!(:find).and_return(@answer_set_element)
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
  
    it "should find the answer_set_element requested" do
      AnswerSetElement.should_receive(:find).with("1").and_return(@answer_set_element)
      do_get
    end
  
    it "should assign the found answer_set_element for the view" do
      do_get
      assigns[:answer_set_element].should equal(@answer_set_element)
    end
  end

  describe "handling GET /answer_set_elements/1.xml" do

    before(:each) do
      mock_user
      @answer_set_element = mock_model(AnswerSetElement, :to_xml => "XML")
      AnswerSetElement.stub!(:find).and_return(@answer_set_element)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the answer_set_element requested" do
      AnswerSetElement.should_receive(:find).with("1").and_return(@answer_set_element)
      do_get
    end
  
    it "should render the found answer_set_element as xml" do
      @answer_set_element.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /answer_set_elements/new" do

    before(:each) do
      mock_user
      @answer_set_element = mock_model(AnswerSetElement)
      AnswerSetElement.stub!(:new).and_return(@answer_set_element)
      @answer_set_element.stub!(:parent_element_id=)
      @answer_set_element.stub!(:form_id=)
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
  
    it "should create an new answer_set_element" do
      AnswerSetElement.should_receive(:new).and_return(@answer_set_element)
      do_get
    end
  
    it "should not save the new answer_set_element" do
      @answer_set_element.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new answer_set_element for the view" do
      do_get
      assigns[:answer_set_element].should equal(@answer_set_element)
    end
  end

  describe "handling GET /answer_set_elements/1/edit" do

    before(:each) do
      mock_user
      @answer_set_element = mock_model(AnswerSetElement)
      AnswerSetElement.stub!(:find).and_return(@answer_set_element)
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
  
    it "should find the answer_set_element requested" do
      AnswerSetElement.should_receive(:find).and_return(@answer_set_element)
      do_get
    end
  
    it "should assign the found AnswerSetElement for the view" do
      do_get
      assigns[:answer_set_element].should equal(@answer_set_element)
    end
  end

  describe "handling POST /answer_set_elements" do

    before(:each) do
      mock_user
      @answer_set_element = mock_model(AnswerSetElement, :to_param => "1")
      AnswerSetElement.stub!(:new).and_return(@answer_set_element)
    end
    
    describe "with successful save" do
  
      def do_post
        @answer_set_element.should_receive(:save).and_return(true)
        post :create, :answer_set_element => {}
      end
  
      it "should create a new answer_set_element" do
        AnswerSetElement.should_receive(:new).with({}).and_return(@answer_set_element)
        do_post
      end

      it "should redirect to the new answer_set_element" do
        do_post
        response.should redirect_to(answer_set_element_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @answer_set_element.should_receive(:save).and_return(false)
        post :create, :answer_set_element => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /answer_set_elements/1" do

    before(:each) do
      mock_user
      @answer_set_element = mock_model(AnswerSetElement, :to_param => "1")
      AnswerSetElement.stub!(:find).and_return(@answer_set_element)
    end
    
    describe "with successful update" do

      def do_put
        @answer_set_element.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the answer_set_element requested" do
        AnswerSetElement.should_receive(:find).with("1").and_return(@answer_set_element)
        do_put
      end

      it "should update the found answer_set_element" do
        do_put
        assigns(:answer_set_element).should equal(@answer_set_element)
      end

      it "should assign the found answer_set_element for the view" do
        do_put
        assigns(:answer_set_element).should equal(@answer_set_element)
      end

      it "should redirect to the answer_set_element" do
        do_put
        response.should redirect_to(answer_set_element_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @answer_set_element.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /answer_set_elements/1" do

    before(:each) do
      mock_user
      @answer_set_element = mock_model(AnswerSetElement, :destroy => true)
      AnswerSetElement.stub!(:find).and_return(@answer_set_element)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the answer_set_element requested" do
      AnswerSetElement.should_receive(:find).with("1").and_return(@answer_set_element)
      do_delete
    end
  
    it "should call destroy on the found answer_set_element" do
      @answer_set_element.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the answer_set_elements list" do
      do_delete
      response.should redirect_to(answer_set_elements_url)
    end
  end
end