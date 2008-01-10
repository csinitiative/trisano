require File.dirname(__FILE__) + '/../spec_helper'

describe EthnicitiesController do
  describe "handling GET /ethnicities" do

    before(:each) do
      @ethnicity = mock_model(Ethnicity)
      Ethnicity.stub!(:find).and_return([@ethnicity])
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
  
    it "should find all ethnicities" do
      Ethnicity.should_receive(:find).with(:all).and_return([@ethnicity])
      do_get
    end
  
    it "should assign the found ethnicities for the view" do
      do_get
      assigns[:ethnicities].should == [@ethnicity]
    end
  end

  describe "handling GET /ethnicities.xml" do

    before(:each) do
      @ethnicity = mock_model(Ethnicity, :to_xml => "XML")
      Ethnicity.stub!(:find).and_return(@ethnicity)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all ethnicities" do
      Ethnicity.should_receive(:find).with(:all).and_return([@ethnicity])
      do_get
    end
  
    it "should render the found ethnicities as xml" do
      @ethnicity.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /ethnicities/1" do

    before(:each) do
      @ethnicity = mock_model(Ethnicity)
      Ethnicity.stub!(:find).and_return(@ethnicity)
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
  
    it "should find the ethnicity requested" do
      Ethnicity.should_receive(:find).with("1").and_return(@ethnicity)
      do_get
    end
  
    it "should assign the found ethnicity for the view" do
      do_get
      assigns[:ethnicity].should equal(@ethnicity)
    end
  end

  describe "handling GET /ethnicities/1.xml" do

    before(:each) do
      @ethnicity = mock_model(Ethnicity, :to_xml => "XML")
      Ethnicity.stub!(:find).and_return(@ethnicity)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the ethnicity requested" do
      Ethnicity.should_receive(:find).with("1").and_return(@ethnicity)
      do_get
    end
  
    it "should render the found ethnicity as xml" do
      @ethnicity.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /ethnicities/new" do

    before(:each) do
      @ethnicity = mock_model(Ethnicity)
      Ethnicity.stub!(:new).and_return(@ethnicity)
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
  
    it "should create an new ethnicity" do
      Ethnicity.should_receive(:new).and_return(@ethnicity)
      do_get
    end
  
    it "should not save the new ethnicity" do
      @ethnicity.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new ethnicity for the view" do
      do_get
      assigns[:ethnicity].should equal(@ethnicity)
    end
  end

  describe "handling GET /ethnicities/1/edit" do

    before(:each) do
      @ethnicity = mock_model(Ethnicity)
      Ethnicity.stub!(:find).and_return(@ethnicity)
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
  
    it "should find the ethnicity requested" do
      Ethnicity.should_receive(:find).and_return(@ethnicity)
      do_get
    end
  
    it "should assign the found Ethnicity for the view" do
      do_get
      assigns[:ethnicity].should equal(@ethnicity)
    end
  end

  describe "handling POST /ethnicities" do

    before(:each) do
      @ethnicity = mock_model(Ethnicity, :to_param => "1")
      Ethnicity.stub!(:new).and_return(@ethnicity)
    end
    
    describe "with successful save" do
  
      def do_post
        @ethnicity.should_receive(:save).and_return(true)
        post :create, :ethnicity => {}
      end
  
      it "should create a new ethnicity" do
        Ethnicity.should_receive(:new).with({}).and_return(@ethnicity)
        do_post
      end

      it "should redirect to the new ethnicity" do
        do_post
        response.should redirect_to(ethnicity_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @ethnicity.should_receive(:save).and_return(false)
        post :create, :ethnicity => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /ethnicities/1" do

    before(:each) do
      @ethnicity = mock_model(Ethnicity, :to_param => "1")
      Ethnicity.stub!(:find).and_return(@ethnicity)
    end
    
    describe "with successful update" do

      def do_put
        @ethnicity.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the ethnicity requested" do
        Ethnicity.should_receive(:find).with("1").and_return(@ethnicity)
        do_put
      end

      it "should update the found ethnicity" do
        do_put
        assigns(:ethnicity).should equal(@ethnicity)
      end

      it "should assign the found ethnicity for the view" do
        do_put
        assigns(:ethnicity).should equal(@ethnicity)
      end

      it "should redirect to the ethnicity" do
        do_put
        response.should redirect_to(ethnicity_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @ethnicity.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /ethnicities/1" do

    before(:each) do
      @ethnicity = mock_model(Ethnicity, :destroy => true)
      Ethnicity.stub!(:find).and_return(@ethnicity)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the ethnicity requested" do
      Ethnicity.should_receive(:find).with("1").and_return(@ethnicity)
      do_delete
    end
  
    it "should call destroy on the found ethnicity" do
      @ethnicity.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the ethnicities list" do
      do_delete
      response.should redirect_to(ethnicities_url)
    end
  end
end