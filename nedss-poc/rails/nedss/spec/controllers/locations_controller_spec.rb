require File.dirname(__FILE__) + '/../spec_helper'

describe LocationsController do
  describe "handling GET /locations for a person" do

    before(:each) do
      mimic_before_filter
      @location = mock_model(Location)
      @person_entity.stub!(:current_locations).and_return([@location])
    end
  
    def do_get
      get :index, :person_id => "1"
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
  
    it "should find all locations" do
      @person_entity.should_receive(:current_locations).and_return([@locations])
      do_get
    end
  
    it "should assign the found locations for the view" do
      do_get
      assigns[:locations].should == [@location]
    end
  end

  describe "handling GET /locations.xml" do

    before(:each) do
      mimic_before_filter
      @location = mock_model(Location, :to_xml => "XML")
      @person_entity.stub!(:current_locations).and_return(@location)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index, :person_id => "1"
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all locations" do
      @person_entity.should_receive(:current_locations).and_return([@location])
      do_get
    end
  
    it "should render the found locations as xml" do
      @location.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /locations/1" do

    before(:each) do
      mimic_before_filter
      @location = mock_model(Location)
      @person_entity.stub!(:current_location_by_id).and_return(@location)
    end
  
    def do_get
      get :show, :person_id => "1", :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  
    it "should find the locations requested" do
      @person_entity.should_receive(:current_location_by_id).with("1").and_return(@location)
      do_get
    end
  
    it "should assign the found locations for the view" do
      do_get
      assigns[:location].should equal(@location)
    end
  end

  describe "handling GET /locations/1.xml" do

    before(:each) do
      mimic_before_filter
      @location = mock_model(Location, :to_xml => "XML")
      @person_entity.stub!(:current_location_by_id).and_return(@location)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :person_id => "1", :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the locations requested" do
      @person_entity.should_receive(:current_location_by_id).with("1").and_return(@location)
      do_get
    end
  
    it "should render the found locations as xml" do
      @location.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /locations/new" do

    before(:each) do
      mimic_before_filter

      @entities_location = mock_model(EntitiesLocation)
      @location = mock_model(Location)
      @address = mock_model(Address)

      EntitiesLocation.stub!(:new).and_return(@entities_location)
      Location.stub!(:new).and_return(@location)
      Address.stub!(:new).and_return(@address)
    end
  
    def do_get
      get :new, :person_id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render new template" do
      do_get
      response.should render_template('new')
    end
  
    it "should create a new EntitiesLocation, location, and Address" do
      EntitiesLocation.should_receive(:new).and_return(@entities_location)
      Location.should_receive(:new).and_return(@entities_location)
      Address.should_receive(:new).and_return(@address)
      do_get
    end
  
    it "should not save the new locations" do
      @entities_locations.should_not_receive(:save)
      @location.should_not_receive(:save)
      @address.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new locations for the view" do
      do_get
      assigns[:location].should equal(@location)
      assigns[:entities_location].should equal(@entities_location)
      assigns[:address].should equal(@address)
    end
  end

  describe "handling GET /locations/1/edit" do

    before(:each) do
      mimic_before_filter

      @entities_location = mock_model(EntitiesLocation)
      @location = mock_model(Location)
      @address = mock_model(Address)

      @locations = [@location]
      @entities_locations = [@entities_location]

      @locations.stub!(:find).and_return(@location)
      @entities_locations.stub!(:find).and_return(@entities_location)
      @person_entity.stub!(:entities_locations).and_return(@entities_locations)
      @person_entity.stub!(:locations).and_return(@locations)
      @location.stub!(:current_address).and_return(@address)
    end
  
    def do_get
      get :edit, :person_id => "1", :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the locations requested" do
      @locations.should_receive(:find).and_return(@location)
      @entities_locations.should_receive(:find).and_return(@entities_location)
      @person_entity.should_receive(:entities_locations).and_return(@entities_locations)
      @person_entity.should_receive(:locations).and_return(@locations)
      @location.should_receive(:current_address).and_return(@address)
      do_get
    end
  
    it "should assign the found Locations for the view" do
      do_get
      assigns[:entities_location].should equal(@entities_location)
      assigns[:location].should equal(@location)
      assigns[:address].should equal(@address)
    end
  end

  describe "handling POST /locations" do

    before(:each) do
      mimic_before_filter

      @address = mock_model(Address, :to_param => "1")
      addresses = [@address]
      addresses.should_receive(:<<).and_return(true)

      @location = mock_model(Location, :to_param => "1", :addresses => addresses)
      @entities_location = mock_model(EntitiesLocation, :to_param => "1")
      @entities_location.should_receive(:location=).with(@location).and_return(@location)

      Location.stub!(:new).and_return(@location)
      EntitiesLocation.stub!(:new).and_return(@entities_location)
      Address.stub!(:new).and_return(@address)

      @entities_locations = [@entities_location]
    end
    
    describe "with successful save" do
  
      def do_post
        @address.should_receive(:valid?).and_return(true)
        @person_entity.should_receive(:entities_locations).and_return(@entities_locations)
        @entities_locations.should_receive(:<<).and_return(true)

        post :create, :address => {}, :entities_location => {}, :person_id => "1"
      end
  
      it "should create a new location" do
        Location.should_receive(:new).and_return(@location)
        EntitiesLocation.should_receive(:new).with({}).and_return(@entities_location)
        Address.should_receive(:new).with({}).and_return(@address)
        do_post
      end

      it "should redirect to the new locations" do
        do_post
        response.should redirect_to(person_path("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @address.should_receive(:valid?).and_return(false)

        post :create, :locations => {}, :person_id => "1"
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

      @entities_location = mock_model(EntitiesLocation, :to_param => "1", :attributes= => true)
      @location = mock_model(Location, :to_param => "1")
      @locations = [@location]
      @locations.stub!(:find).and_return(@location)
      @entities_locations = [@entities_location]
      @entities_locations.stub!(:find).and_return(@entities_location)

      @address = mock_model(Address, :to_param => "1")
      Address.stub!(:new).and_return(@address)

      @person_entity.stub!(:entities_locations).and_return(@entities_locations)
      @person_entity.stub!(:locations).and_return(@locations)
    end
    
    describe "with successful update" do

      def do_put
        @entities_location.should_receive(:transaction).and_return(true)
        put :update, :person_id => "1", :id => "1"
      end

      it "should find the location requested" do
        @person_entity.should_receive(:locations).and_return(@locations)
        @person_entity.should_receive(:entities_locations).and_return(@entities_locations)
        @locations.should_receive(:find).with("1").and_return(@location)
        @entities_locations.should_receive(:find).and_return(@entities_location)

        do_put
      end

      it "should update the found locations" do
        do_put
        assigns(:location).should equal(@location)
        assigns(:entities_location).should equal(@entities_location)
        assigns(:address).should equal(@address)
      end

      it "should assign the found locations for the view" do
        do_put
        assigns(:location).should equal(@location)
        assigns(:entities_location).should equal(@entities_location)
        assigns(:address).should equal(@address)
      end

      it "should redirect to the locations" do
        do_put
        response.should redirect_to(person_path("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @entities_location.should_receive(:transaction).and_return(false)
        put :update, :person_id => "1", :id => "1"
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

      @entities_location = mock_model(EntitiesLocation, :destroy => true)
      @entities_locations = [@entities_location]
      @person_entity.should_receive(:entities_locations).and_return(@entities_locations)
      @entities_locations.should_receive(:find).and_return(@entities_location)
    end
  
    def do_delete
      delete :destroy, :person_id => "1", :id => "1"
    end

    it "should find the locations requested" do
      do_delete
    end
  
    it "should call destroy on the found locations" do
      @entities_location.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the locations list" do
      do_delete
      response.should redirect_to(person_path("1"))
    end
  end

  def mimic_before_filter
    @person_id = 1
    @person_entity = mock_model(PersonEntity)
    @person = mock_model(Person)
    PersonEntity.stub!(:find).with("1").and_return(@person_entity)
    @person_entity.stub!(:current).and_return(@person)
  end
end
