require File.dirname(__FILE__) + '/../spec_helper'

describe ExternalCodesController do
  describe "handling GET /external_codes" do

    before(:each) do
      @external_code = mock_model(ExternalCode)
      ExternalCode.stub!(:find).and_return([@external_code])
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
  
    it "should find all external_codes" do
      ExternalCode.should_receive(:find).with(:all).and_return([@external_code])
      do_get
    end
  
    it "should assign the found external_codes for the view" do
      do_get
      assigns[:external_codes].should == [@external_code]
    end
  end

#  describe "handling GET /external_codes.xml" do
#
#    before(:each) do
#      @external_code = mock_model(ExternalCode, :to_xml => "XML")
#      ExternalCode.stub!(:find).and_return(@external_code)
#    end
#  
#    def do_get
###      @request.env["HTTP_ACCEPT"] = "application/xml"
#      get :index
#    end
#  
#    it "should be successful" do
#      do_get
#      response.should be_success
#    end
#
#    it "should find all external_codes" do
#      ExternalCode.should_receive(:find).with(:all).and_return([@external_code])
#      do_get
#    end
#  
#    it "should render the found external_codes as xml" do
#      @external_code.should_receive(:to_xml).and_return("XML")
#      do_get
#      response.body.should == "XML"
#    end
#  end

  describe "handling GET /external_codes/1" do

    before(:each) do
      @external_code = mock_model(ExternalCode)
      ExternalCode.stub!(:find).and_return(@external_code)
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
  
    it "should find the external_code requested" do
      ExternalCode.should_receive(:find).with("1").and_return(@external_code)
      do_get
    end
  
    it "should assign the found external_code for the view" do
      do_get
      assigns[:external_code].should equal(@external_code)
    end
  end

  describe "handling GET /external_codes/1.xml" do

    before(:each) do
      @external_code = mock_model(ExternalCode, :to_xml => "XML")
      ExternalCode.stub!(:find).and_return(@external_code)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the external_code requested" do
      ExternalCode.should_receive(:find).with("1").and_return(@external_code)
      do_get
    end
  
    it "should render the found external_code as xml" do
      @external_code.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /external_codes/new" do

    before(:each) do
      @external_code = mock_model(ExternalCode)
      ExternalCode.stub!(:new).and_return(@external_code)
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
  
    it "should create an new external_code" do
      ExternalCode.should_receive(:new).and_return(@external_code)
      do_get
    end
  
    it "should not save the new external_code" do
      @external_code.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new external_code for the view" do
      do_get
      assigns[:external_code].should equal(@external_code)
    end
  end

  describe "handling GET /external_codes/1/edit" do

    before(:each) do
      @external_code = mock_model(ExternalCode)
      ExternalCode.stub!(:find).and_return(@external_code)
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
  
    it "should find the external_code requested" do
      ExternalCode.should_receive(:find).and_return(@external_code)
      do_get
    end
  
    it "should assign the found ExternalCode for the view" do
      do_get
      assigns[:external_code].should equal(@external_code)
    end
  end

  describe "handling POST /external_codes" do

    before(:each) do
      @external_code = mock_model(ExternalCode, :to_param => "1")
      ExternalCode.stub!(:new).and_return(@external_code)
    end
    
    describe "with successful save" do
  
      def do_post
        @external_code.should_receive(:save).and_return(true)
        post :create, :external_code => {}
      end
  
      it "should create a new external_code" do
        ExternalCode.should_receive(:new).with({}).and_return(@external_code)
        do_post
      end

      it "should redirect to the new external_code" do
        do_post
        response.should redirect_to(code_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @external_code.should_receive(:save).and_return(false)
        post :create, :external_code => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /external_codes/1" do

    before(:each) do
      @external_code = mock_model(ExternalCode, :to_param => "1")
      ExternalCode.stub!(:find).and_return(@external_code)
    end
    
    describe "with successful update" do

      def do_put
        @external_code.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the external_code requested" do
        ExternalCode.should_receive(:find).with("1").and_return(@external_code)
        do_put
      end

      it "should update the found external_code" do
        do_put
        assigns(:external_code).should equal(@external_code)
      end

      it "should assign the found external_code for the view" do
        do_put
        assigns(:external_code).should equal(@external_code)
      end

      it "should redirect to the external_code" do
        do_put
        response.should redirect_to(code_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @external_code.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /external_codes/1" do

    before(:each) do
      @external_code = mock_model(ExternalCode, :destroy => true)
      ExternalCode.stub!(:find).and_return(@external_code)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the external_code requested" do
      ExternalCode.should_receive(:find).with("1").and_return(@external_code)
      do_delete
    end
  
    it "should call destroy on the found external_code" do
      @external_code.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the external_codes list" do
      do_delete
      response.should redirect_to(codes_url)
    end
  end
end
