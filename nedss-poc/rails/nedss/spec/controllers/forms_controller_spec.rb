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
      Form.should_receive(:find).with(:all).and_return([@form])
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
      Form.should_receive(:find).with(:all).and_return([@form])
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
        @form.should_receive(:save).and_return(true)
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
        @form.should_receive(:save).and_return(false)
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
        put :update, :id => "1"
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
        put :update, :id => "1"
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
end