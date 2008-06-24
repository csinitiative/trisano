require File.dirname(__FILE__) + '/../spec_helper'

describe HealthFacilitiesController do
  
  describe "handling GET /health_facilities" do

    before(:each) do
      mock_health_facility_request
    end
  
    def do_get
      get :index, :cmr_id => "1"
    end
  
    it "should always return HTTP Response Code: Method not allowed" do
      do_get
      response.headers["Status"].should == "405 Method Not Allowed"
    end
    
  end
  
  describe "handling GET /health_facilities/1" do

    before(:each) do
      mock_health_facility_request
    end
  
    def do_get
      get :show, :cmr_id => "1", :id => "1"
    end

    it "should always return HTTP Response Code: Method not allowed" do
      do_get
      response.headers["Status"].should == "405 Method Not Allowed"
    end
  
  end
  
  describe "handling GET /health_facilities/new" do

    fixtures :codes
    
    before(:each) do
      mock_health_facility_request
    end
  
    def do_get
      get :new, {:cmr_id => "1", :role_id => codes(:participant_diagnosing_health_facility).id.to_s }
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render new template" do
      do_get
      response.should render_template('new')
    end
  
    it "should create an new health facility" do
      Entity.should_receive(:new).and_return(@health_facility)
      do_get
    end
  
    it "should not save the new health facility" do
      @health_facility.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new health facility for the view that has a role id set" do
      do_get
      assigns[:health_facility].role_id.should == codes(:participant_diagnosing_health_facility).id
    end
    
  end
  
  describe "handling GET /health_facilities/new without a role_id provided" do

    before(:each) do
      mock_health_facility_request
    end
  
    def do_get
      get :new, {:cmr_id => "1" }
    end

    it "should return a bad_request status" do
      do_get
      response.headers["Status"].should == "400 Bad Request"
    end
    
  end

  describe "handling GET /health_facilities/1/edit for a diagnosing facility" do

    fixtures :codes
    
    before(:each) do
      mock_health_facility_request
    end
  
    def do_get
      get :edit, {:cmr_id => "1", :id => "1", :role_id => codes(:participant_diagnosing_health_facility).id.to_s }
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should assign the found health facility for the view" do
      do_get
      assigns[:health_facility].should equal(@health_facility)
    end
  end
  
  describe "handling GET /health_facilities/1/edit for a hospitalization facility" do

    fixtures :codes
    
    before(:each) do
      mock_health_facility_request
    end
  
    def do_get
      get :edit, {:cmr_id => "1", :id => "1", :role_id => codes(:participant_hospitalized_at).id.to_s }
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should assign the found health facility for the view" do
      do_get
      assigns[:health_facility].should equal(@health_facility)
    end
  end
  
  describe "handling GET /health_facilities/1/edit without a role_id provided" do
 
    before(:each) do
      mock_health_facility_request
    end
  
    def do_get
      get :new, {:cmr_id => "1" }
    end

    it "should return a bad_request status" do
      do_get
      response.headers["Status"].should == "400 Bad Request"
    end
    
  end
  
  describe "handling POST /health_facilities for a diagnosing facility" do

    fixtures :codes
     
    before(:each) do
      mock_user
      @event = mock_event
      @health_facility = mock_model(Participation, :to_param => "1", :errors => stub("errors", :count => 0, :null_object => true))
      @health_facilities = []
      Event.stub!(:find).and_return(@event)
      Participation.stub!(:new).and_return(@health_facility)
      @event.stub!(:diagnosing_health_facilities).and_return(@health_facilities)
    end
    
    describe "with successful save" do
  
      def do_post
        @health_facilities.should_receive("<<").and_return(true)
        post :create, {:health_facility => {
            :role_id => codes(:participant_diagnosing_health_facility).id.to_s 
          }, :cmr_id => "1" }
      end
  
      it "should create a new health facility" do
        Participation.should_receive(:new).and_return(@health_facility)
        do_post
      end

      it "should replace the health facility list" do
        do_post
        response.should have_rjs(:replace_html, "diagnosing-health-facilities-list")
      end
    end
    
    describe "with failed save" do

      def do_post
        @health_facilities.should_receive("<<").and_return(nil)
        
        post :create, :health_facility => {
          :role_id => codes(:participant_diagnosing_health_facility).id.to_s 
        }
      end
  
      it "should not replace any content with RJS" do
        do_post
        response.should have_text(/alert/) 
        response.should have_text(/Validation failed/) 
      end
    end
    
  end
  
  describe "handling POST /health_facilities for a hospitalization facility" do

    fixtures :codes
     
    before(:each) do
      mock_user
      @event = mock_event
      @health_facility = mock_model(Participation, :to_param => "1", :errors => stub("errors", :count => 0, :null_object => true))
      @health_facilities = []
      Event.stub!(:find).and_return(@event)
      Participation.stub!(:new).and_return(@health_facility)
      @event.stub!(:hospitalized_health_facilities).and_return(@health_facilities)
    end
    
    describe "with successful save" do
  
      def do_post
        @health_facilities.should_receive("<<").and_return(true)
        post :create, {:health_facility => {
            :role_id => codes(:participant_hospitalized_at).id.to_s
          }, :cmr_id => "1" }
      end
  
      it "should create a new health facility" do
        Participation.should_receive(:new).and_return(@health_facility)
        do_post
      end

      it "should replace the health facility list" do
        do_post
        response.should have_rjs(:replace_html, "hospitalized-health-facilities-list")
      end
    end
    
    describe "with failed save" do

      def do_post
        @health_facilities.should_receive("<<").and_return(nil)
        
        post :create, :health_facility => {
          :role_id => codes(:participant_hospitalized_at).id.to_s 
        }
      end
  
      it "should not replace any content with RJS" do
        do_post
        response.should have_text(/alert/) 
        response.should have_text(/Validation failed/) 
      end
    end
    
  end
  
  describe "handling POST /health_facilities without a role_id" do

    fixtures :codes
     
    before(:each) do
      mock_user
      @event = mock_event
      @health_facility = mock_model(Participation, :to_param => "1", :errors => stub("errors", :count => 0, :null_object => true))
      @health_facilities = []
      Event.stub!(:find).and_return(@event)
      Participation.stub!(:new).and_return(@health_facility)
      @event.stub!(:diagnosing_health_facilities).and_return(@health_facilities)
    end
  
    def do_post
      post :create, {:health_facility => {}, :cmr_id => "1" }
    end

    it "should return a bad_request status" do
      do_post
      response.headers["Status"].should == "400 Bad Request"
    end
    
  end
  
  describe "handling PUT /health_facilities/1" do

    before(:each) do
      
      mock_user
      @event = mock_event
      @health_facility = mock_model(Participation, :to_param => "1", 
        :errors => stub("errors", :count => 0, :null_object => true))
      @health_facilities = [@health_facility]
      Event.stub!(:find).and_return(@event)
      @event.stub!(:diagnosing_health_facilities).and_return(@health_facilities)
      @health_facilities.stub!(:find).and_return(@health_facility)
      @health_facility.stub!(:role_id).and_return(codes(:participant_diagnosing_health_facility).id.to_s)
      @health_facility_entity = mock_model(Entity)
      @health_facility_entity_place = mock_model(Place)
      @health_facility.stub!(:secondary_entity).and_return(@health_facility_entity)
      @health_facility_entity.stub!(:place).and_return(@health_facility_entity_place)
      @health_facility_entity_place.stub!(:name).and_return("Central Hospital")
      Participation.stub!(:new).and_return(@health_facility)
    end
    
    describe "with successful update" do

      def do_put
        @health_facility.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1", :health_facility => { :role_id => codes(:participant_diagnosing_health_facility).id.to_s }
      end

      it "should assign the found health facility for the view" do
        do_put
        assigns(:health_facility).should equal(@health_facility)
      end

      it "should replace the health facility list" do
        do_put
        response.should have_rjs(:replace_html, "diagnosing-health-facilities-list")
      end

    end
    
    describe "with failed update" do

      def do_put
        @health_facility.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1", :health_facility => { :role_id => codes(:participant_diagnosing_health_facility).id.to_s }
      end

      it "should not replace any content with RJS" do
        do_put
        response.should have_text(/alert/) 
        response.should have_text(/Validation failed/) 
      end

    end
  end
  
  describe "handling PUT /health_facilities/1 without a role_id" do

    before(:each) do
      
      mock_user
      @event = mock_event
      @health_facility = mock_model(Participation, :to_param => "1", 
        :errors => stub("errors", :count => 0, :null_object => true))
      @health_facilities = [@health_facility]
      Event.stub!(:find).and_return(@event)
      @event.stub!(:diagnosing_health_facilities).and_return(@health_facilities)
      @health_facilities.stub!(:find).and_return(@health_facility)
      @health_facility.stub!(:role_id).and_return(codes(:participant_diagnosing_health_facility).id.to_s)
      @health_facility_entity = mock_model(Entity)
      @health_facility_entity_place = mock_model(Place)
      @health_facility.stub!(:secondary_entity).and_return(@health_facility_entity)
      @health_facility_entity.stub!(:place).and_return(@health_facility_entity_place)
      @health_facility_entity_place.stub!(:name).and_return("Central Hospital")
      Participation.stub!(:new).and_return(@health_facility)
    end
  
    def do_put
      put :update, :id => "1", :health_facility => {}
    end

    it "should return a bad_request status" do
      do_put
      response.headers["Status"].should == "400 Bad Request"
    end
    
  end
  
  describe "handling DELETE /health_facilities/1" do

    before(:each) do
      mock_user
      @event = mock_event
      Event.stub!(:find).and_return(@event)
    end
  
    def do_delete
      delete :destroy, :id => "1", :cmr_id => "1"
    end

    it "should always return HTTP Response Code: Method not allowed" do
      do_delete
      response.headers["Status"].should == "405 Method Not Allowed"
    end
  end
  
  def mock_health_facility_request
    mock_user
    @event = mock_event
    @health_facility = mock_model(Participation)
    Event.stub!(:find).and_return(@event)
    @health_facilities = [@health_facility]
    @health_facilities.stub!(:find).and_return(@health_facility)
    @event.stub!(:diagnosing_health_facilities).and_return(@health_facilities)
    @event.stub!(:hospitalized_health_facilities).and_return(@health_facilities)
  end


end
