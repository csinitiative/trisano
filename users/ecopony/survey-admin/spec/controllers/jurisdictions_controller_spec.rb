require File.dirname(__FILE__) + '/../spec_helper'

describe JurisdictionsController do
  describe "handling GET /jurisdictions" do

    before(:each) do
      @jurisdiction = mock_model(Jurisdiction)
      Jurisdiction.stub!(:find).and_return([@jurisdiction])
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
  
    it "should find all jurisdictions" do
      Jurisdiction.should_receive(:find).with(:all).and_return([@jurisdiction])
      do_get
    end
  
    it "should assign the found jurisdictions for the view" do
      do_get
      assigns[:jurisdictions].should == [@jurisdiction]
    end
  end

  describe "handling GET /jurisdictions.xml" do

    before(:each) do
      @jurisdiction = mock_model(Jurisdiction, :to_xml => "XML")
      Jurisdiction.stub!(:find).and_return(@jurisdiction)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all jurisdictions" do
      Jurisdiction.should_receive(:find).with(:all).and_return([@jurisdiction])
      do_get
    end
  
    it "should render the found jurisdictions as xml" do
      @jurisdiction.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /jurisdictions/1" do

    before(:each) do
      @jurisdiction = mock_model(Jurisdiction)
      Jurisdiction.stub!(:find).and_return(@jurisdiction)
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
  
    it "should find the jurisdiction requested" do
      Jurisdiction.should_receive(:find).with("1").and_return(@jurisdiction)
      do_get
    end
  
    it "should assign the found jurisdiction for the view" do
      do_get
      assigns[:jurisdiction].should equal(@jurisdiction)
    end
  end

  describe "handling GET /jurisdictions/1.xml" do

    before(:each) do
      @jurisdiction = mock_model(Jurisdiction, :to_xml => "XML")
      Jurisdiction.stub!(:find).and_return(@jurisdiction)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the jurisdiction requested" do
      Jurisdiction.should_receive(:find).with("1").and_return(@jurisdiction)
      do_get
    end
  
    it "should render the found jurisdiction as xml" do
      @jurisdiction.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /jurisdictions/new" do

    before(:each) do
      @jurisdiction = mock_model(Jurisdiction)
      Jurisdiction.stub!(:new).and_return(@jurisdiction)
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
  
    it "should create an new jurisdiction" do
      Jurisdiction.should_receive(:new).and_return(@jurisdiction)
      do_get
    end
  
    it "should not save the new jurisdiction" do
      @jurisdiction.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new jurisdiction for the view" do
      do_get
      assigns[:jurisdiction].should equal(@jurisdiction)
    end
  end

  describe "handling GET /jurisdictions/1/edit" do

    before(:each) do
      @jurisdiction = mock_model(Jurisdiction)
      Jurisdiction.stub!(:find).and_return(@jurisdiction)
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
  
    it "should find the jurisdiction requested" do
      Jurisdiction.should_receive(:find).and_return(@jurisdiction)
      do_get
    end
  
    it "should assign the found Jurisdiction for the view" do
      do_get
      assigns[:jurisdiction].should equal(@jurisdiction)
    end
  end

  describe "handling POST /jurisdictions" do

    before(:each) do
      @jurisdiction = mock_model(Jurisdiction, :to_param => "1")
      Jurisdiction.stub!(:new).and_return(@jurisdiction)
    end
    
    describe "with successful save" do
  
      def do_post
        @jurisdiction.should_receive(:save).and_return(true)
        post :create, :jurisdiction => {}
      end
  
      it "should create a new jurisdiction" do
        Jurisdiction.should_receive(:new).with({}).and_return(@jurisdiction)
        do_post
      end

      it "should redirect to the new jurisdiction" do
        do_post
        response.should redirect_to(jurisdiction_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @jurisdiction.should_receive(:save).and_return(false)
        post :create, :jurisdiction => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /jurisdictions/1" do

    before(:each) do
      @jurisdiction = mock_model(Jurisdiction, :to_param => "1")
      Jurisdiction.stub!(:find).and_return(@jurisdiction)
    end
    
    describe "with successful update" do

      def do_put
        @jurisdiction.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the jurisdiction requested" do
        Jurisdiction.should_receive(:find).with("1").and_return(@jurisdiction)
        do_put
      end

      it "should update the found jurisdiction" do
        do_put
        assigns(:jurisdiction).should equal(@jurisdiction)
      end

      it "should assign the found jurisdiction for the view" do
        do_put
        assigns(:jurisdiction).should equal(@jurisdiction)
      end

      it "should redirect to the jurisdiction" do
        do_put
        response.should redirect_to(jurisdiction_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @jurisdiction.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /jurisdictions/1" do

    before(:each) do
      @jurisdiction = mock_model(Jurisdiction, :destroy => true)
      Jurisdiction.stub!(:find).and_return(@jurisdiction)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the jurisdiction requested" do
      Jurisdiction.should_receive(:find).with("1").and_return(@jurisdiction)
      do_delete
    end
  
    it "should call destroy on the found jurisdiction" do
      @jurisdiction.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the jurisdictions list" do
      do_delete
      response.should redirect_to(jurisdictions_url)
    end
  end
end