require File.dirname(__FILE__) + '/../spec_helper'

describe DiseasesController do
  describe "handling GET /diseases" do

    before(:each) do
      @disease = mock_model(Disease)
      Disease.stub!(:find).and_return([@disease])
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
  
    it "should find all diseases" do
      Disease.should_receive(:find).with(:all).and_return([@disease])
      do_get
    end
  
    it "should assign the found diseases for the view" do
      do_get
      assigns[:diseases].should == [@disease]
    end
  end

  describe "handling GET /diseases.xml" do

    before(:each) do
      @disease = mock_model(Disease, :to_xml => "XML")
      Disease.stub!(:find).and_return(@disease)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all diseases" do
      Disease.should_receive(:find).with(:all).and_return([@disease])
      do_get
    end
  
    it "should render the found diseases as xml" do
      @disease.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /diseases/1" do

    before(:each) do
      @disease = mock_model(Disease)
      Disease.stub!(:find).and_return(@disease)
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
  
    it "should find the disease requested" do
      Disease.should_receive(:find).with("1").and_return(@disease)
      do_get
    end
  
    it "should assign the found disease for the view" do
      do_get
      assigns[:disease].should equal(@disease)
    end
  end

  describe "handling GET /diseases/1.xml" do

    before(:each) do
      @disease = mock_model(Disease, :to_xml => "XML")
      Disease.stub!(:find).and_return(@disease)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the disease requested" do
      Disease.should_receive(:find).with("1").and_return(@disease)
      do_get
    end
  
    it "should render the found disease as xml" do
      @disease.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /diseases/new" do

    before(:each) do
      @disease = mock_model(Disease)
      Disease.stub!(:new).and_return(@disease)
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
  
    it "should create an new disease" do
      Disease.should_receive(:new).and_return(@disease)
      do_get
    end
  
    it "should not save the new disease" do
      @disease.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new disease for the view" do
      do_get
      assigns[:disease].should equal(@disease)
    end
  end

  describe "handling GET /diseases/1/edit" do

    before(:each) do
      @disease = mock_model(Disease)
      Disease.stub!(:find).and_return(@disease)
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
  
    it "should find the disease requested" do
      Disease.should_receive(:find).and_return(@disease)
      do_get
    end
  
    it "should assign the found Disease for the view" do
      do_get
      assigns[:disease].should equal(@disease)
    end
  end

  describe "handling POST /diseases" do

    before(:each) do
      @disease = mock_model(Disease, :to_param => "1")
      Disease.stub!(:new).and_return(@disease)
    end
    
    describe "with successful save" do
  
      def do_post
        @disease.should_receive(:save).and_return(true)
        post :create, :disease => {}
      end
  
      it "should create a new disease" do
        Disease.should_receive(:new).with({}).and_return(@disease)
        do_post
      end

      it "should redirect to the new disease" do
        do_post
        response.should redirect_to(disease_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @disease.should_receive(:save).and_return(false)
        post :create, :disease => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /diseases/1" do

    before(:each) do
      @disease = mock_model(Disease, :to_param => "1")
      Disease.stub!(:find).and_return(@disease)
    end
    
    describe "with successful update" do

      def do_put
        @disease.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the disease requested" do
        Disease.should_receive(:find).with("1").and_return(@disease)
        do_put
      end

      it "should update the found disease" do
        do_put
        assigns(:disease).should equal(@disease)
      end

      it "should assign the found disease for the view" do
        do_put
        assigns(:disease).should equal(@disease)
      end

      it "should redirect to the disease" do
        do_put
        response.should redirect_to(disease_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @disease.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /diseases/1" do

    before(:each) do
      @disease = mock_model(Disease, :destroy => true)
      Disease.stub!(:find).and_return(@disease)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the disease requested" do
      Disease.should_receive(:find).with("1").and_return(@disease)
      do_delete
    end
  
    it "should call destroy on the found disease" do
      @disease.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the diseases list" do
      do_delete
      response.should redirect_to(diseases_url)
    end
  end
end