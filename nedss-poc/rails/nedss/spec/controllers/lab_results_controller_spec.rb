require File.dirname(__FILE__) + '/../spec_helper'

describe LabResultsController do
  describe "handling GET /lab_results" do

    before(:each) do
      set_up_local_mocks
      @lab_results.stub!(:find).and_return([@lab_result])
    end
  
    def do_get
      get :index, :cmr_id => "1"
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
  
    it "should find all lab_results" do
      @lab_results.should_receive(:find).with(:all).and_return([@lab_result])
      do_get
    end
  
    it "should assign the found lab_results for the view" do
      do_get
      assigns[:lab_results].should == [@lab_result]
    end
  end

  describe "handling GET /lab_results/1" do

    before(:each) do
      set_up_local_mocks
      @lab_results.stub!(:find).and_return(@lab_result)
    end
  
    def do_get
      get :show, :cmr_id => "1", :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  
    it "should find the lab_result requested" do
      @lab_results.should_receive(:find).with("1").and_return(@lab_result)
      do_get
    end
  
    it "should assign the found lab_result for the view" do
      do_get
      assigns[:lab_result].should equal(@lab_result)
    end
  end

  describe "handling GET /lab_results/new" do

    before(:each) do
      set_up_local_mocks
      LabResult.stub!(:new).and_return(@lab_result)
    end
  
    def do_get
      get :new, :cmr_id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render new template" do
      do_get
      response.should render_template('new')
    end
  
    it "should create an new lab_result" do
      LabResult.should_receive(:new).and_return(@lab_result)
      do_get
    end
  
    it "should not save the new lab_result" do
      @lab_result.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new lab_result for the view" do
      do_get
      assigns[:lab_result].should equal(@lab_result)
    end
  end

  describe "handling GET /lab_results/1/edit" do

    before(:each) do
      set_up_local_mocks
      @lab_results.stub!(:find).and_return(@lab_result)
    end
  
    def do_get
      get :edit, :id => "1", :cmr_id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the lab_result requested" do
      @lab_results.should_receive(:find).and_return(@lab_result)
      do_get
    end
  
    it "should assign the found LabResult for the view" do
      do_get
      assigns[:lab_result].should equal(@lab_result)
    end
  end

  describe "handling POST /lab_results" do

    before(:each) do
      set_up_local_mocks
      LabResult.stub!(:new).and_return(@lab_result)
    end
    
    describe "with successful save" do
  
      def do_post
        @lab_results.should_receive(:<<).and_return(true)
        post :create, :lab_result => {}, :cmr_id => "1"
      end
  
      it "should create a new lab_result" do
        LabResult.should_receive(:new).with({}).and_return(@lab_result)
        do_post
      end

      it "should update lab-result list" do
        do_post
        response.should have_rjs(:replace_html, "lab-result-list")
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @lab_results.should_receive(:<<).and_return(false)
        post :create, :lab_result => {}, :cmr_id => "1"
      end
  
      it "should send javascript alert" do
        do_post
        response.should have_text(/alert/) 
        response.should have_text(/Validation failed/) 
      end
      
    end
  end

  describe "handling PUT /lab_results/1" do

    before(:each) do
      set_up_local_mocks
      @lab_results.stub!(:find).and_return(@lab_result)
    end
    
    describe "with successful update" do

      def do_put
        @lab_result.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1", :cmr_id => "1"
      end

      it "should find the lab_result requested" do
        @lab_results.should_receive(:find).with("1").and_return(@lab_result)
        do_put
      end

      it "should update the found lab_result" do
        do_put
        assigns(:lab_result).should equal(@lab_result)
      end

      it "should assign the found lab_result for the view" do
        do_put
        assigns(:lab_result).should equal(@lab_result)
      end

      it "should update the lab_result list" do
        do_put
        response.should have_rjs(:replace_html, "lab-result-list")
      end

    end
    
    describe "with failed update" do

      def do_put
        @lab_result.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1", :cmr_id => "1"
      end

      it "should send javascript alert" do
        do_put
        response.should have_text(/alert/) 
        response.should have_text(/Validation failed/) 
      end

    end
  end

  describe "handling DELETE /lab_results/1" do

    before(:each) do
      set_up_local_mocks
    end
  
    def do_delete
      delete :destroy, :id => "1", :cmr_id => "1"
    end

    it "should always return HTTP Response Code: Method not allowed" do
      do_delete
      response.headers["Status"].should == "405 Method Not Allowed"
    end
  end

  def set_up_local_mocks
    mock_user
    @lab_result = mock_model(LabResult, :to_param => "1", :errors => stub("errors", :count => 0, :null_object => true))

    @lab_results = mock(Array, :null_object => :true)

    @cmr = mock_model(Event, :to_param => "1")
    @cmr.stub!(:lab_results).and_return(@lab_results)
    Event.stub!(:find).with("1").and_return(@cmr)
    
    @errors.stub!(:full_messages).and_return("some text")
  end
end
