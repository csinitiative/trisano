require File.dirname(__FILE__) + '/../spec_helper'

describe EntitiesController do
  describe "handling GET /entities" do

    before(:each) do
      mock_user
      @entity = mock_model(Entity)
      Entity.stub!(:find).and_return([@entity])
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
  
    it "should find all entities" do
      Entity.should_receive(:find).with(:all, :conditions => {}).and_return([@entity])
      do_get
    end
  
    it "should assign the found entities for the view" do
      do_get
      assigns[:entities].should == [@entity]
    end

    describe "handling type paramter on /entities" do

      def do_get_with_param(param)
        get :index, :type => param
      end

      it "should allow legal types" do
        do_get_with_param 'person'
        response.should be_success
      end

      it "should 404 with illegal type" do
        do_get_with_param 'illegal'
        response.should_not be_success
        response.headers["Status"].should =~ /404/
      end

      it "should change no type to type=all" do
        # Not implemented yet
      end

      it "should properly set conditions for type=person" do
        Entity.should_receive(:find).with(:all, :conditions => {:entity_type => "person"} )
        do_get_with_param 'person'
      end

      it "should properly set conditions for type=all" do
        # Not implemented yet
      end
    end
  end

  describe "handling GET /entities.xml" do

    before(:each) do
      mock_user
      @entity = mock_model(Entity, :to_xml => "XML")
      Entity.stub!(:find).and_return(@entity)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all entities" do
      Entity.should_receive(:find).with(:all, :conditions => {}).and_return([@entity])
      do_get
    end
  
    it "should render the found entities as xml" do
      @entity.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /entities/1" do

    before(:each) do
      mock_user
      @entity = mock_model(Entity)
      Entity.stub!(:find).and_return(@entity)
      @entity.stub!(:entity_type).and_return('person')
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
  
    it "should set type and find the entity requested" do
      Entity.should_receive(:find).twice.with("1").and_return(@entity)
      @entity.should_receive(:entity_type).and_return('person')
      do_get
    end
  
    it "should assign the found entity for the view" do
      do_get
      assigns[:entity].should equal(@entity)
    end
  end

  describe "handling GET /entities/1.xml" do

    before(:each) do
      mock_user
      @entity = mock_model(Entity, :to_xml => "XML")
      Entity.stub!(:find).and_return(@entity)
      @entity.stub!(:entity_type).and_return('person')
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should set type and find the entity requested" do
      Entity.should_receive(:find).twice.with("1").and_return(@entity)
      do_get
    end
  
    it "should render the found entity as xml" do
      @entity.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /entities/new" do

    before(:each) do
      mock_user
      @entity = mock_model(Entity)
      Entity.stub!(:new).and_return(@entity)
    end
  
    def do_get
      get :new
    end

    def do_get_with_param(param)
      get :new, :type => param
    end

    it "should not be successful without type parameter" do
      do_get
      response.should_not be_success
      response.headers["Status"].should =~ /404/
    end
  
    it "should be successful with type parameter" do
      do_get_with_param 'person'
      response.should be_success
    end
  
    it "should render new template" do
      do_get_with_param 'person'
      response.should render_template('new')
    end
  
    it "should create a new entity" do
      Entity.should_receive(:new).with(:person => {}, :entities_location => {}, :address => {}, :telephone => {}).and_return(@entity)
      do_get_with_param 'person'
    end
  
    it "should not save the new entity" do
      @entity.should_not_receive(:save)
      do_get_with_param 'person'
    end
  
    it "should assign the new entity for the view" do
      do_get_with_param 'person'
      assigns[:entity].should equal(@entity)
    end
  end

  describe "handling GET /entities/1/edit" do

    before(:each) do
      mock_user
      @entity = mock_model(Entity)
      Entity.stub!(:find).and_return(@entity)
      @entity.stub!(:entity_type).and_return('person')
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
  
    it "should find the entity requested" do
      Entity.should_receive(:find).twice.and_return(@entity)
      do_get
    end
  
    it "should assign the found Entity for the view" do
      do_get
      assigns[:entity].should equal(@entity)
    end
  end

  describe "handling POST /entities" do

    before(:each) do
      mock_user
      @entity = mock_model(Entity, :to_param => "1")
      Entity.stub!(:new).and_return(@entity)
    end
    
    describe "with successful save" do
  
      def do_post
        @entity.should_receive(:save).and_return(true)
        post :create, :entity => {:entity_type => 'person'}
      end
  
      it "should create a new entity" do
        Entity.should_receive(:new).with({"entity_type" => "person"}).and_return(@entity)
        do_post
      end

      it "should redirect to the new entity" do
        do_post
        response.should redirect_to(entity_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @entity.should_receive(:save).and_return(false)
        post :create, :entity => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /entities/1" do

    before(:each) do
      mock_user
      @entity = mock_model(Entity, :to_param => "1")
      Entity.stub!(:find).and_return(@entity)
      @entity.stub!(:entity_type).and_return('person')
    end
    
    describe "with successful update" do

      def do_put
        @entity.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the entity requested" do
        Entity.should_receive(:find).twice.with("1").and_return(@entity)
        do_put
      end

      it "should update the found entity" do
        do_put
        assigns(:entity).should equal(@entity)
      end

      it "should assign the found entity for the view" do
        do_put
        assigns(:entity).should equal(@entity)
      end

      it "should redirect to the entity" do
        do_put
        response.should redirect_to(entity_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @entity.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /entities/1" do

    before(:each) do
      mock_user
      @entity = mock_model(Entity, :destroy => true)
      Entity.stub!(:find).and_return(@entity)
      @entity.stub!(:entity_type).and_return('person')
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    #it "should find the entity requested" do
    #  Entity.should_receive(:find).twice.with("1").and_return(@entity)
    #  do_delete
    #end
  
    #it "should call destroy on the found entity" do
    #  @entity.should_receive(:destroy)
    #  do_delete
    #end
  
    it "should return 405" do
      do_delete
      response.response_code.should == 405
    end
  end
end
