require File.dirname(__FILE__) + '/../spec_helper'

describe LocationsController do
  describe "handling GET /locations" do
    it "should redirect to the entities show page" do
      get :index, :entity_id => "1"
      response.should redirect_to(entity_path("1"))
    end
  end

  describe "handling GET /locations/1" do
    it "should redirect to the entities show page" do
      get :index, :entity_id => "1"
      response.should redirect_to(entity_path("1"))
    end
  end

  describe "handling GET /locations/new" do

    before(:each) do
      mimic_before_filter
      @location = mock_model(Location)
      Location.stub!(:new).and_return(@location)
    end
  
    def do_get
      get :new, :entity_id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render new template" do
      do_get
      response.should render_template('new')
    end
  
    it "should create a new location" do
      Location.should_receive(:new).with(:entities_location => {:entity_id => @entity.id}, :address => {}, :telephone => {}).and_return(@location)
      do_get
    end
  
    it "should not save the new location" do
      @location.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new location for the view" do
      do_get
      assigns[:location].should equal(@location)
    end
  end

  describe "handling GET /locations/1/edit" do

    before(:each) do
      mimic_before_filter
      @location = mock_model(Location)
      @entities_location = mock_model(EntitiesLocation)
      @array = mock(Array)
      
      @entity.stub!(:locations).and_return(@array)
      @array.stub!(:find).and_return(@location)
      @entity.stub!(:entities_locations).and_return(@array)
      @array.stub!(:find_by_location_id).and_return(@entities_location)
      @entities_location.stub!(:attributes).and_return({})
      @location.stub!(:entities_location=).and_return(true)
    end
  
    def do_get
      get :edit, :entity_id => "1", :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the location requested" do
      @entity.should_receive(:locations).and_return(@array)
      @array.should_receive(:find).and_return(@location)
      @entity.should_receive(:entities_locations).and_return(@array)
      @array.should_receive(:find_by_location_id).and_return(@entities_location)
      @entities_location.should_receive(:attributes).and_return({})
      @location.should_receive(:entities_location=).and_return(true)
      do_get
    end
  
    it "should assign the found Location for the view" do
      do_get
      assigns[:location].should equal(@location)
    end
  end

  describe "handling POST /locations" do

    before(:each) do
      mimic_before_filter
      @location = mock_model(Location, :to_param => "1")
      Location.stub!(:new).and_return(@location)
    end
    
    describe "with successful save" do
  
      def do_post
        @location.should_receive(:save).and_return(true)
        post :create, :entity_id => "1"
      end
  
      it "should create a new location" do
        Location.should_receive(:new).and_return(@location)
        do_post
      end

      it "should redirect to the new location" do
        do_post
        response.should redirect_to(entity_path("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @location.should_receive(:save).and_return(false)
        post :create, :location => {}, :entity_id => "1"
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /locations/1" do

    before(:each) do
      mimic_before_filter
      @array = mock_model(Array)
      @entity.stub!(:locations).and_return(@array)
      @array.stub!(:find).and_return(@location)
    end
    
    describe "with successful update" do

      def do_put
        @location.should_receive(:update_attributes).and_return(true)
        put :update, :entity_id => "1", :id => "1"
      end

      it "should find the location requested" do
        @entity.should_receive(:locations).and_return(@array)
        @array.should_receive(:find).with("1").and_return(@location)
        do_put
      end

      it "should update the found location" do
        do_put
        assigns(:location).should equal(@location)
      end

      it "should assign the found location for the view" do
        do_put
        assigns(:location).should equal(@location)
      end

      it "should redirect to the location" do
        do_put
        response.should redirect_to(entity_path("1"))
      end
    end
    
    describe "with failed update" do

      def do_put
        @location.should_receive(:update_attributes).and_return(false)
        put :update, :entity_id => "1", :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /locations/1" do

    before(:each) do
      mimic_before_filter
      @location = mock_model(Location, :to_param => "1")
      @array = mock_model(Array)
      @entity.stub!(:locations).and_return(@array)
      @array.stub!(:find).and_return(@location)
      @location.stub!(:destroy).and_return(true)
    end
  
    def do_delete
      delete :destroy, :entity_id => "1", :id => "1"
    end

    it "should find the location requested" do
      @entity.should_receive(:locations).and_return(@array)
      @array.should_receive(:find).with("1").and_return(@location)
      do_delete
    end
  
    it "should call destroy on the found location" do
      @location.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the locations list" do
      do_delete
      p @entity
      response.should redirect_to(entity_path("1"))
    end
  end

  def mimic_before_filter
    @entity = mock_model(Entity, :to_param => "1")
    Entity.stub!(:find).with("1").and_return(@entity)
    @entity.stub!(:entity_type).and_return('person')
  end
end
