require File.dirname(__FILE__) + '/../spec_helper'

# Many specs are commented out. The mocking exercise is not a small undertaking.
# Perhaps it can be chipped away at.

describe MorbidityEventsController do
  describe "handling GET /events" do

    before(:each) do
      mock_user
      @event = mock_event
      MorbidityEvent.stub!(:find).and_return([@event])
      @user.stub!(:jurisdiction_ids_for_privilege).with(:view_event).and_return([75])
      @event.stub!(:read_attribute).and_return('MorbidityEvent') 
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
  
    it "should find all events" do
      MorbidityEvent.should_receive(:find).and_return([@event])
      do_get
    end
  
    it "should assign the found events for the view" do
      do_get
      assigns[:events].should == [@event]
    end
  end

  #    describe "handling GET /events.xml" do
  #  
  #      before(:each) do
  #      mock_user
  #      @event = mock_event
  #      MorbidityEvent.stub!(:find).and_return([@event])
  #      end
  #    
  #      def do_get
  #        @request.env["HTTP_ACCEPT"] = "application/xml"
  #        get :index
  #      end
  #    
  #      it "should be successful" do
  #        do_get
  #        response.should be_success
  #      end
  #  
  #    it "should find all events" do
  #      MorbidityEvent.should_receive(:find).with(:all).and_return([@event])
  #      do_get
  #    end
  #    
  #      it "should render the found events as xml" do
  #        @event.should_receive(:to_xml).and_return("XML")
  #        do_get
  #        response.body.should == "XML"
  #      end
  #    end

  describe "handling GET /events/1 with view entitlement" do

    before(:each) do
      mock_user
      @event = mock_event
      Event.stub!(:find).and_return(@event)
      @user.stub!(:is_entitled_to_in?).with(:view_event, 75).and_return(true)
      @event.stub!(:read_attribute).and_return('MorbidityEvent') 
    end
  
    def do_get
      get :show, :id => "75"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  
    it "should find the event requested" do
      Event.should_receive(:find).once().with("75").and_return(@event)
      do_get
    end
  
    it "should assign the found event for the view" do
      do_get
      assigns[:event].should equal(@event)
    end
  end

  describe "handling GETting a real event of the wrong type" do

    before(:each) do
      mock_user
      @event = mock_event
      Event.stub!(:find).and_return(@event)
      @user.stub!(:is_entitled_to_in?).with(:view_event, 75).and_return(true)
      @event.stub!(:read_attribute).and_return('ContactEvent') 
    end
  
    def do_get
      get :show, :id => "75"
    end

    it "should find the event requested" do
      Event.should_receive(:find).with("75").and_return(@event)
      do_get
    end

    it "should return a 404" do
      do_get
      response.response_code.should == 404
    end

    it "should render the public 404 page" do
      do_get
      response.should render_template("#{RAILS_ROOT}/public/404.html")
    end

  end
  
  describe "handling GET /events/1 without view entitlement" do

    before(:each) do
      mock_user
      @event = mock_event
      Event.stub!(:find).and_return(@event)
      @user.stub!(:is_entitled_to_in?).with(:view_event, 75).and_return(false)
      @event.stub!(:read_attribute).and_return('MorbidityEvent') 
    end
  
    def do_get
      get :show, :id => "75"
    end

    it "should find the event requested" do
      Event.should_receive(:find).with("75").and_return(@event)
      do_get
    end
  
    it "should be be a 403" do
      do_get
      response.response_code.should == 403
    end
  
  end
  
  #  describe "handling GET /events/1.xml" do
  #
  #    before(:each) do
  #      mock_user
  #      @event = mock_model(MorbidityEvent, :to_xml => "XML")
  #      MorbidityEvent.stub!(:find).and_return([@event])
  #    end
  #  
  #    def do_get
  #      @request.env["HTTP_ACCEPT"] = "application/xml"
  #      get :show, :id => "1"
  #    end
  #
  #    it "should be successful" do
  #      do_get
  #      response.should be_success
  #    end
  #  
  #    it "should find the event requested" do
  #      MorbidityEvent.should_receive(:find).with("1").and_return([@event])
  #      do_get
  #    end
  #  
  #    it "should render the found event as xml" do
  #      @event.should_receive(:to_xml).and_return("XML")
  #      do_get
  #      response.body.should == "XML"
  #    end
  #  end
  #
  describe "handling GET /events/new" do
  
    before(:each) do
      mock_user
      @event = mock_event
      MorbidityEvent.stub!(:new).and_return(@event)
      @user.stub!(:is_entitled_to?).with(:create_event).and_return(true)
      @event.stub!(:read_attribute).and_return('MorbidityEvent') 
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
    
    it "should create an new event" do
      MorbidityEvent.should_receive(:new).and_return(@event)
      do_get
    end
    
    it "should not save the new event" do
      @event.should_not_receive(:save)
      do_get
    end
    
    it "should assign the new event for the view" do
      do_get
      assigns[:event].should equal(@event)
    end
  end
  
  describe "handling GET /events/1/edit with update entitlement" do

    before(:each) do
      mock_user
      @event = mock_event
      @form_reference = mock_model(FormReference)
      @form = mock_model(Form, :null_object => true)

      Event.stub!(:find).and_return(@event)
      @event.stub!(:get_investigation_forms).and_return([@form])
      @user.stub!(:is_entitled_to_in?).with(:update_event, 75).and_return(true)
      @event.stub!(:read_attribute).and_return('MorbidityEvent') 
    end
  
    def do_get
      get :edit, :id => "75"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the event requested" do
      Event.should_receive(:find).and_return(@event)
      do_get
    end
  
    it "should assign the found MorbidityEvent for the view" do
      do_get
      assigns[:event].should equal(@event)
    end
  end

  #  describe "handling POST /events" do
  #
  #    before(:each) do
  #      mock_user
  #      @event = mock_model(MorbidityEvent, :to_param => "1")
  #      MorbidityEvent.stub!(:new).and_return(@event)
  #    end
  #    
  #    describe "with successful save" do
  #  
  #      def do_post
  #        @event.should_receive(:save).and_return(true)
  #        post :create, :event => {}
  #      end
  #  
  #      it "should create a new event" do
  #        MorbidityEvent.should_receive(:new).with({}).and_return(@event)
  #        do_post
  #      end
  #
  #      it "should redirect to the new event" do
  #        do_post
  #        response.should redirect_to(event_url("1"))
  #      end
  #      
  #    end
  #    
  #    describe "with failed save" do
  #
  #      def do_post
  #        @event.should_receive(:save).and_return(false)
  #        post :create, :event => {}
  #      end
  #  
  #      it "should re-render 'new'" do
  #        do_post
  #        response.should render_template('new')
  #      end
  #      
  #    end
  #  end
  #
  #  describe "handling PUT /events/1" do
  #
  #    before(:each) do
  #      mock_user
  #      @event = mock_model(MorbidityEvent, :to_param => "1")
  #      MorbidityEvent.stub!(:find).and_return(@event)
  #    end
  #    
  #    describe "with successful update" do
  #
  #      def do_put
  #        @event.should_receive(:update_attributes).and_return(true)
  #        put :update, :id => "1"
  #      end
  #
  #      it "should find the event requested" do
  #        MorbidityEvent.should_receive(:find).with("1").and_return(@event)
  #        do_put
  #      end
  #
  #      it "should update the found event" do
  #        do_put
  #        assigns(:event).should equal(@event)
  #      end
  #
  #      it "should assign the found event for the view" do
  #        do_put
  #        assigns(:event).should equal(@event)
  #      end
  #
  #      it "should redirect to the event" do
  #        do_put
  #        response.should redirect_to(event_url("1"))
  #      end
  #
  #    end
  #    
  #    describe "with failed update" do
  #
  #      def do_put
  #        @event.should_receive(:update_attributes).and_return(false)
  #        put :update, :id => "1"
  #      end
  #
  #      it "should re-render 'edit'" do
  #        do_put
  #        response.should render_template('edit')
  #      end
  #
  #    end
  #  end
  #
  #  describe "handling DELETE /events/1" do
  #
  #    before(:each) do
  #      mock_user
  #      @event = mock_model(MorbidityEvent, :destroy => true)
  #      MorbidityEvent.stub!(:find).and_return(@event)
  #    end
  #  
  #    def do_delete
  #      delete :destroy, :id => "1"
  #    end
  #
  #    it "should find the event requested" do
  #      MorbidityEvent.should_receive(:find).with("1").and_return(@event)
  #      do_delete
  #    end
  #  
  #    it "should call destroy on the found event" do
  #      @event.should_receive(:destroy)
  #      do_delete
  #    end
  #  
  #    it "should redirect to the events list" do
  #      do_delete
  #      response.should redirect_to(events_url)
  #    end
  #  end

  describe "handling JURISDICTION requests /events/1/jurisdiction" do
    before(:each) do
      mock_user
      @user.stub!(:is_entitled_to_in?).with(:route_event_to_any_lhd, 1).and_return(true)
      @user.stub!(:is_entitled_to_in?).with(:create_event, "2").and_return(true)
      @user.stub!(:jurisdiction_ids_for_privilege).with(:view_event).and_return([1])

      @jurisdiction = mock_model(Participation)
      @jurisdiction.stub!(:secondary_entity_id).and_return(1)

      @event = mock_model(MorbidityEvent, :to_param => "1")
      @event.stub!(:active_jurisdiction).and_return(@jurisdiction)
      MorbidityEvent.stub!(:find).and_return(@event)
    end

    describe "with successful routing" do
      def do_route_event
        request.env['HTTP_REFERER'] = "/some_path"
        @event.should_receive(:route_to_jurisdiction).and_return(true)
        post :jurisdiction, :id => "1", :jurisdiction_id => "2"
      end
      
      it "should find the event requested" do
        MorbidityEvent.should_receive(:find).with("1").and_return(@event)
        do_route_event
      end
      
      it "should redirect to the where it was called from" do
        do_route_event
        response.should redirect_to("http://test.host/some_path")
      end
    end

    describe "with failed routing" do
      def do_route_event
        request.env['HTTP_REFERER'] = "/some_path"
        @event.errors.should_receive(:add_to_base)
        @event.should_receive(:route_to_jurisdiction).and_raise()
        post :jurisdiction, :id => "1", :jurisdiction_id => "2"
      end

      it "should render the show view" do
        do_route_event
        response.should render_template('show')
      end
    end
  end
end
