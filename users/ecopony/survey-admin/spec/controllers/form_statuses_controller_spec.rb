require File.dirname(__FILE__) + '/../spec_helper'

describe FormStatusesController do
  describe "handling GET /form_statuses" do

    before(:each) do
      @form_status = mock_model(FormStatus)
      FormStatus.stub!(:find).and_return([@form_status])
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
  
    it "should find all form_statuses" do
      FormStatus.should_receive(:find).and_return([@form_status])
      do_get
    end
  
    it "should assign the found form_statuses for the view" do
      do_get
      assigns[:form_statuses].should == [@form_status]
    end
  end

  describe "handling GET /form_statuses.xml" do

    before(:each) do
      @form_status = mock_model(FormStatus, :to_xml => "XML")
      FormStatus.stub!(:find).and_return(@form_status)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all form_statuses" do
      FormStatus.should_receive(:find).and_return([@form_status])
      do_get
    end
  
    it "should render the found form_statuses as xml" do
      @form_status.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /form_statuses/1" do

    before(:each) do
      @form_status = mock_model(FormStatus)
      FormStatus.stub!(:find).and_return(@form_status)
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
  
    it "should find the form_status requested" do
      FormStatus.should_receive(:find).with("1").and_return(@form_status)
      do_get
    end
  
    it "should assign the found form_status for the view" do
      do_get
      assigns[:form_status].should equal(@form_status)
    end
  end

  describe "handling GET /form_statuses/1.xml" do

    before(:each) do
      @form_status = mock_model(FormStatus, :to_xml => "XML")
      FormStatus.stub!(:find).and_return(@form_status)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the form_status requested" do
      FormStatus.should_receive(:find).with("1").and_return(@form_status)
      do_get
    end
  
    it "should render the found form_status as xml" do
      @form_status.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /form_statuses/new" do

    before(:each) do
      @form_status = mock_model(FormStatus)
      FormStatus.stub!(:new).and_return(@form_status)
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
  
    it "should create an new form_status" do
      FormStatus.should_receive(:new).and_return(@form_status)
      do_get
    end
  
    it "should not save the new form_status" do
      @form_status.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new form_status for the view" do
      do_get
      assigns[:form_status].should equal(@form_status)
    end
  end

  describe "handling GET /form_statuses/1/edit" do

    before(:each) do
      @form_status = mock_model(FormStatus)
      FormStatus.stub!(:find).and_return(@form_status)
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
  
    it "should find the form_status requested" do
      FormStatus.should_receive(:find).and_return(@form_status)
      do_get
    end
  
    it "should assign the found FormStatus for the view" do
      do_get
      assigns[:form_status].should equal(@form_status)
    end
  end

  describe "handling POST /form_statuses" do

    before(:each) do
      @form_status = mock_model(FormStatus, :to_param => "1")
      FormStatus.stub!(:new).and_return(@form_status)
    end
    
    describe "with successful save" do
  
      def do_post
        @form_status.should_receive(:save).and_return(true)
        post :create, :form_status => {}
      end
  
      it "should create a new form_status" do
        FormStatus.should_receive(:new).with({}).and_return(@form_status)
        do_post
      end

      it "should redirect to the new form_status" do
        do_post
        response.should redirect_to(form_status_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @form_status.should_receive(:save).and_return(false)
        post :create, :form_status => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /form_statuses/1" do

    before(:each) do
      @form_status = mock_model(FormStatus, :to_param => "1")
      FormStatus.stub!(:find).and_return(@form_status)
    end
    
    describe "with successful update" do

      def do_put
        @form_status.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the form_status requested" do
        FormStatus.should_receive(:find).with("1").and_return(@form_status)
        do_put
      end

      it "should update the found form_status" do
        do_put
        assigns(:form_status).should equal(@form_status)
      end

      it "should assign the found form_status for the view" do
        do_put
        assigns(:form_status).should equal(@form_status)
      end

      it "should redirect to the form_status" do
        do_put
        response.should redirect_to(form_status_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @form_status.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /form_statuses/1" do

    before(:each) do
      @form_status = mock_model(FormStatus, :destroy => true)
      FormStatus.stub!(:find).and_return(@form_status)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the form_status requested" do
      FormStatus.should_receive(:find).with("1").and_return(@form_status)
      do_delete
    end
  
    it "should call destroy on the found form_status" do
      @form_status.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the form_statuses list" do
      do_delete
      response.should redirect_to(form_statuses_url)
    end
  end
end