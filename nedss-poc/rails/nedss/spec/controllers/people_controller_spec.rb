require File.dirname(__FILE__) + '/../spec_helper'

describe PeopleController do
  describe "handling GET /people" do

    before(:each) do
      @person_entity = mock_model(PersonEntity)
      PersonEntity.stub!(:find_by_sql).and_return([@person_entity])
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
  
    it "should find all people" do
      PersonEntity.should_receive(:find_by_sql).and_return([@person_entity])
      do_get
    end
  
    it "should assign the found people for the view" do
      do_get
      assigns[:person_entities].should == [@person_entity]
    end
  end

  describe "handling GET /people.xml" do

    before(:each) do
      @person_entity = mock_model(PersonEntity, :to_xml => "XML")
      PersonEntity.stub!(:find_by_sql).and_return(@person_entity)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all people" do
      PersonEntity.should_receive(:find_by_sql).and_return([@person_entity])
      do_get
    end
  
    it "should render the found people as xml" do
      @person_entity.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /people/1" do

    before(:each) do
      @person_entity = mock_model(PersonEntity)
      @person = mock_model(Person)
      PersonEntity.stub!(:find).and_return(@person_entity)
      @person_entity.stub!(:current).and_return(@person)
      @location = mock_model(Location)
      @person_entity.stub!(:current_locations).and_return([@location])
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
  
    it "should find the person requested" do
      PersonEntity.should_receive(:find).with("1").and_return(@person_entity)
      do_get
    end
  
    it "should assign the found person for the view" do
      do_get
      assigns[:person].should equal(@person)
    end
  end

  describe "handling GET /people/1.xml" do

    before(:each) do
      @person_entity = mock_model(PersonEntity, :to_xml => "XML")
      @person = mock_model(Person)
      PersonEntity.stub!(:find).and_return(@person_entity)
      @person_entity.stub!(:current).and_return(@person)
      @location = mock_model(Location)
      @person_entity.stub!(:current_locations).and_return([@location])
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the person requested" do
      PersonEntity.should_receive(:find).with("1").and_return(@person_entity)
      do_get
    end
  
    it "should render the found person as xml" do
      @person.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /people/new" do

    before(:each) do
      @person = mock_model(Person)
      Person.stub!(:new).and_return(@person)
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
  
    it "should create an new person" do
      Person.should_receive(:new).and_return(@person)
      do_get
    end
  
    it "should not save the new person" do
      @person.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new person for the view" do
      do_get
      assigns[:person].should equal(@person)
    end
  end

  describe "handling GET /people/1/edit" do

    before(:each) do
      @person_entity = mock_model(PersonEntity)
      @person = mock_model(Person)
      PersonEntity.stub!(:find).and_return(@person_entity)
      @person_entity.stub!(:current).and_return(@person)
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
  
    it "should find the person requested" do
      PersonEntity.should_receive(:find).and_return(@person_entity)
#      Entity.should_receive(:current).and_return(@person)
      do_get
    end
  
    it "should assign the found Person for the view" do
      do_get
      assigns[:person].should equal(@person)
    end
  end

  describe "handling POST /people" do

    before(:each) do
      @person = mock_model(Person, :to_param => '1')
      @person_entity = mock_model(PersonEntity, :to_param => "1")
      PersonEntity.stub!(:new).and_return(@person_entity)
      Person.stub!(:new).and_return(@person)
    end
    
    describe "with successful save" do
  
      def do_post
        @person_entity.should_receive(:save).and_return(true)
        post :create, :person => {}
      end
  
      it "should create a new person" do
        PersonEntity.should_receive(:new).and_return(@person_entity)
        Person.should_receive(:new).with({}).and_return(@person)
        @person_entity.should_receive(:current=).with(@person).and_return(true)
        do_post
      end

      it "should redirect to the new person" do
        @person_entity.should_receive(:current=).with(@person).and_return(true)
        do_post
        response.should redirect_to(person_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @person_entity.should_receive(:current=).with(@person)
        @person_entity.should_receive(:save).and_return(false)
        post :create, :person => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /people/1" do

    before(:each) do
      @person_entity = mock_model(PersonEntity, :to_param => "1")
      @person = mock_model(Person, :to_param => "1")
      PersonEntity.stub!(:find).and_return(@person_entity)
      Person.stub!(:new).and_return(@person)
      @person_entity.stub!(:people).and_return([])
    end
    
    describe "with successful update" do

      def do_put
        @person_entity.people.should_receive(:<<).and_return(true)
        put :update, :id => "1"
      end

      it "should find the person requested" do
        PersonEntity.should_receive(:find).with("1").and_return(@person_entity)
        do_put
      end

      it "should update the found person" do
        do_put
        assigns(:person).should equal(@person)
      end

      it "should assign the found person for the view" do
        do_put
        assigns(:person).should equal(@person)
      end

      it "should redirect to the person" do
        do_put
        response.should redirect_to(person_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @person_entity.people.should_receive(:<<).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /people/1" do

    before(:each) do
      @person_entity = mock_model(PersonEntity, :destroy => true)
      PersonEntity.stub!(:find).and_return(@person_entity)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the person requested" do
      PersonEntity.should_receive(:find).with("1").and_return(@person_entity)
      do_delete
    end
  
    it "should call destroy on the found person" do
      @person_entity.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the people list" do
      do_delete
      response.should redirect_to(people_url)
    end
  end
end
