require File.dirname(__FILE__) + '/../spec_helper'

describe CmrsController do
  describe "handling GET /cmrs" do

    before(:each) do
      @cmr = mock_model(Cmr)
      Cmr.stub!(:find).and_return([@cmr])
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
  
    it "should find all cmrs" do
      Cmr.should_receive(:find).with(:all).and_return([@cmr])
      do_get
    end
  
    it "should assign the found cmrs for the view" do
      do_get
      assigns[:cmrs].should == [@cmr]
    end
  end

  describe "handling GET /cmrs.xml" do

    before(:each) do
      @cmr = mock_model(Cmr, :to_xml => "XML")
      Cmr.stub!(:find).and_return(@cmr)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all cmrs" do
      Cmr.should_receive(:find).with(:all).and_return([@cmr])
      do_get
    end
  
    it "should render the found cmrs as xml" do
      @cmr.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /cmrs/1" do

    before(:each) do
      @cmr = mock_model(Cmr)
      Cmr.stub!(:find).and_return(@cmr)
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
  
    it "should find the cmr requested" do
      Cmr.should_receive(:find).with("1").and_return(@cmr)
      do_get
    end
  
    it "should assign the found cmr for the view" do
      do_get
      assigns[:cmr].should equal(@cmr)
    end
  end

  describe "handling GET /cmrs/1.xml" do

    before(:each) do
      @cmr = mock_model(Cmr, :to_xml => "XML")
      Cmr.stub!(:find).and_return(@cmr)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the cmr requested" do
      Cmr.should_receive(:find).with("1").and_return(@cmr)
      do_get
    end
  
    it "should render the found cmr as xml" do
      @cmr.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /cmrs/new" do

    before(:each) do
      @cmr = mock_model(Cmr)
      Cmr.stub!(:new).and_return(@cmr)
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
  
    it "should create an new cmr" do
      Cmr.should_receive(:new).and_return(@cmr)
      do_get
    end
  
    it "should not save the new cmr" do
      @cmr.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new cmr for the view" do
      do_get
      assigns[:cmr].should equal(@cmr)
    end
  end

  describe "handling GET /cmrs/1/edit" do

    before(:each) do
      @cmr = mock_model(Cmr)
      Cmr.stub!(:find).and_return(@cmr)
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
  
    it "should find the cmr requested" do
      Cmr.should_receive(:find).and_return(@cmr)
      do_get
    end
  
    it "should assign the found Cmr for the view" do
      do_get
      assigns[:cmr].should equal(@cmr)
    end
  end

  describe "handling POST /cmrs" do

    before(:each) do
      @cmr = mock_model(Cmr, :to_param => "1")
      Cmr.stub!(:new).and_return(@cmr)
    end
    
    describe "with successful save" do
  
      def do_post
        @cmr.should_receive(:save).and_return(true)
        post :create, :cmr => {}
      end
  
      it "should create a new cmr" do
        Cmr.should_receive(:new).with({}).and_return(@cmr)
        do_post
      end

      it "should redirect to the new cmr" do
        do_post
        response.should redirect_to(cmr_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @cmr.should_receive(:save).and_return(false)
        post :create, :cmr => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /cmrs/1" do

    before(:each) do
      @cmr = mock_model(Cmr, :to_param => "1")
      Cmr.stub!(:find).and_return(@cmr)
    end
    
    describe "with successful update" do

      def do_put
        @cmr.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the cmr requested" do
        Cmr.should_receive(:find).with("1").and_return(@cmr)
        do_put
      end

      it "should update the found cmr" do
        do_put
        assigns(:cmr).should equal(@cmr)
      end

      it "should assign the found cmr for the view" do
        do_put
        assigns(:cmr).should equal(@cmr)
      end

      it "should redirect to the cmr" do
        do_put
        response.should redirect_to(cmr_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @cmr.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /cmrs/1" do

    before(:each) do
      @cmr = mock_model(Cmr, :destroy => true)
      Cmr.stub!(:find).and_return(@cmr)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the cmr requested" do
      Cmr.should_receive(:find).with("1").and_return(@cmr)
      do_delete
    end
  
    it "should call destroy on the found cmr" do
      @cmr.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the cmrs list" do
      do_delete
      response.should redirect_to(cmrs_url)
    end
  end
end