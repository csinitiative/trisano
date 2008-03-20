require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do
  
  describe "handling GET /search" do
  
    before(:each) do
      mock_user
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

  end
  
   describe "handling GET /search/people" do
  
    before(:each) do
      mock_user
    end
    
    def do_get
      get :people
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render people template" do
      do_get
      response.should render_template('people')
    end

  end
  
  describe "handling GET /search/people with search parameters" do
  
     before(:each) do
       mock_user
      @person = mock_model(Person)
      Person.stub!(:find_by_ts).and_return([@person])
    end
    
    def do_get
      get :people, :name => "Johnson"
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end
    
     it "should execute a search" do
      Person.should_receive(:find_by_ts).and_return([@person])
      do_get
    end
    
    it "should assign the found people for the view" do
      do_get
      assigns[:people].should == ([@person])
    end

    it "should render people template" do
      do_get
      response.should render_template('people')
    end

  end
  
  describe "handling GET /search/cmrs" do
  
    before(:each) do
      mock_user
      @diseases = mock_model(Disease)
      Disease.stub!(:find).and_return([@diseases])
    end
    
    def do_get
      get :cmrs
    end
    
    it "should build a list of diseases" do
      do_get
      assigns[:diseases].should == ([@diseases])
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render cmrs template" do
      do_get
      response.should render_template('cmrs')
    end

  end
  
  describe "handling GET /search/cmrs with search parameters" do
    
    before(:each) do
      mock_user
      @event = mock_model(Event)
      Event.stub!(:find_by_criteria).and_return([@event])
      
      @diseases = mock_model(Disease)
      Disease.stub!(:find).and_return([@diseases])
    end
  
    def do_get
      get :cmrs, :disease => 2
    end
  
    it "should be successful" do
      do_get 
      response.should be_success
    end
    
    it "should build a list of diseases" do
      do_get
      assigns[:diseases].should == ([@diseases])
    end
    
    it "should execute a search" do
      Event.should_receive(:find_by_criteria).and_return([@event])
      do_get
    end
    
    it "should assign the found CMRs for the view" do
      do_get
      assigns[:cmrs].should == ([@event])
    end
    
    it "should render cmrs template" do
      do_get
      response.should render_template('cmrs')
    end

  end
  
end
