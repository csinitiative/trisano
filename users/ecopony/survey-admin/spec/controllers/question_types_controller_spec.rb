require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionTypesController do
  describe "handling GET /question_types" do

    before(:each) do
      @question_type = mock_model(QuestionType)
      QuestionType.stub!(:find).and_return([@question_type])
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
  
    it "should find all question_types" do
      QuestionType.should_receive(:find).and_return([@question_type])
      do_get
    end
  
    it "should assign the found question_types for the view" do
      do_get
      assigns[:question_types].should == [@question_type]
    end
  end

  describe "handling GET /question_types.xml" do

    before(:each) do
      @question_type = mock_model(QuestionType, :to_xml => "XML")
      QuestionType.stub!(:find).and_return(@question_type)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all question_types" do
      QuestionType.should_receive(:find).and_return([@question_type])
      do_get
    end
  
    it "should render the found question_types as xml" do
      @question_type.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /question_types/1" do

    before(:each) do
      @question_type = mock_model(QuestionType)
      QuestionType.stub!(:find).and_return(@question_type)
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
  
    it "should find the question_type requested" do
      QuestionType.should_receive(:find).with("1").and_return(@question_type)
      do_get
    end
  
    it "should assign the found question_type for the view" do
      do_get
      assigns[:question_type].should equal(@question_type)
    end
  end

  describe "handling GET /question_types/1.xml" do

    before(:each) do
      @question_type = mock_model(QuestionType, :to_xml => "XML")
      QuestionType.stub!(:find).and_return(@question_type)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the question_type requested" do
      QuestionType.should_receive(:find).with("1").and_return(@question_type)
      do_get
    end
  
    it "should render the found question_type as xml" do
      @question_type.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /question_types/new" do

    before(:each) do
      @question_type = mock_model(QuestionType)
      QuestionType.stub!(:new).and_return(@question_type)
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
  
    it "should create an new question_type" do
      QuestionType.should_receive(:new).and_return(@question_type)
      do_get
    end
  
    it "should not save the new question_type" do
      @question_type.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new question_type for the view" do
      do_get
      assigns[:question_type].should equal(@question_type)
    end
  end

  describe "handling GET /question_types/1/edit" do

    before(:each) do
      @question_type = mock_model(QuestionType)
      QuestionType.stub!(:find).and_return(@question_type)
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
  
    it "should find the question_type requested" do
      QuestionType.should_receive(:find).and_return(@question_type)
      do_get
    end
  
    it "should assign the found QuestionType for the view" do
      do_get
      assigns[:question_type].should equal(@question_type)
    end
  end

  describe "handling POST /question_types" do

    before(:each) do
      @question_type = mock_model(QuestionType, :to_param => "1")
      QuestionType.stub!(:new).and_return(@question_type)
    end
    
    describe "with successful save" do
  
      def do_post
        @question_type.should_receive(:save).and_return(true)
        post :create, :question_type => {}
      end
  
      it "should create a new question_type" do
        QuestionType.should_receive(:new).with({}).and_return(@question_type)
        do_post
      end

      it "should redirect to the new question_type" do
        do_post
        response.should redirect_to(question_type_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @question_type.should_receive(:save).and_return(false)
        post :create, :question_type => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /question_types/1" do

    before(:each) do
      @question_type = mock_model(QuestionType, :to_param => "1")
      QuestionType.stub!(:find).and_return(@question_type)
    end
    
    describe "with successful update" do

      def do_put
        @question_type.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the question_type requested" do
        QuestionType.should_receive(:find).with("1").and_return(@question_type)
        do_put
      end

      it "should update the found question_type" do
        do_put
        assigns(:question_type).should equal(@question_type)
      end

      it "should assign the found question_type for the view" do
        do_put
        assigns(:question_type).should equal(@question_type)
      end

      it "should redirect to the question_type" do
        do_put
        response.should redirect_to(question_type_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @question_type.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /question_types/1" do

    before(:each) do
      @question_type = mock_model(QuestionType, :destroy => true)
      QuestionType.stub!(:find).and_return(@question_type)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the question_type requested" do
      QuestionType.should_receive(:find).with("1").and_return(@question_type)
      do_delete
    end
  
    it "should call destroy on the found question_type" do
      @question_type.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the question_types list" do
      do_delete
      response.should redirect_to(question_types_url)
    end
  end
end