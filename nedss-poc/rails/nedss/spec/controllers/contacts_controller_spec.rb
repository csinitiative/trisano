require File.dirname(__FILE__) + '/../spec_helper'

describe ContactsController do
  
  describe "handling GET /contacts/new" do

    before(:each) do
      mock_user
      @event = mock_event
      @contact = mock_model(Entity)
      Event.stub!(:find).and_return(@event)
      Entity.stub!(:new).and_return(@contact)
    end
  
    def do_get
      get :new, {:cmr_id => "1"}
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render new template" do
      do_get
      response.should render_template('new')
    end
  
    it "should create a new contact" do
      Entity.should_receive(:new).and_return(@contact)
      do_get
    end
  
    it "should not save the new contact" do
      @contact.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new contact for the view" do
      do_get
      assigns[:contact].should equal(@contact)
    end
  end

  describe "handling GET /contacts/1/edit" do

    before(:each) do
      mock_user
      @event = mock_event
      @contact = mock_model(Participation)
      @contacts = [@contact]
      @contacts.stub!(:find).and_return(@contact)
      Event.stub!(:find).and_return(@event)
      @event.stub!(:contacts).and_return(@contacts)
    end
  
    def do_get
      get :edit, {:cmr_id => "1", :id => "1"}
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should assign the found contact for the view" do
      do_get
      assigns[:contact].should equal(@contact)
    end
  end

  describe "handling POST /contacts" do

    before(:each) do
      mock_user
      @event = mock_event
      @contact = mock_model(Participation, :to_param => "1")
      @person = mock_person_entity
      @contact.stub!(:active_secondary_entity).and_return(@person)
      @contacts = []
      Event.stub!(:find).and_return(@event)
      Participation.stub!(:new).and_return(@contact)
      @event.stub!(:contacts).and_return(@contacts)
      @person.stub!(:case_id).and_return(1)
    end
    
    describe "with successful save" do
  
      def do_post
        @contacts.should_receive("<<").and_return(true)
        post :create, {:contact => {}, :cmr_id => "1"}
      end
  
      it "should create a new contact" do
        Participation.should_receive(:new).and_return(@contact)
        do_post
      end

      it "should replace the contacts list" do
        do_post
        response.should have_rjs(:replace_html, "contact-list")
      end
    end
    
    describe "with failed save" do

      def do_post
        @contacts.should_receive("<<").and_return(nil)
        
        post :create, :contact => {}
      end
  
      it "should not replace any content with RJS" do
        do_post
        response.should have_text(/alert/) 
        response.should have_text(/Validation failed/) 
      end
      
    end
  end

  describe "handling PUT /contacts/1" do

    before(:each) do
      mock_user
      @event = mock_event
      @contact = mock_model(Participation, :to_param => "1")
      @person = mock_person_entity
      @contact.stub!(:active_secondary_entity).and_return(@person)
      @contacts = [@contact]
      @contacts.stub!(:find).and_return(@contact)
      Event.stub!(:find).and_return(@event)
      Participation.stub!(:new).and_return(@contact)
      @event.stub!(:contacts).and_return(@contacts)
      @person.stub!(:case_id).and_return(1)
    end
    
    describe "with successful update" do

      def do_put
        @person.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should update the found contact" do
        do_put
        assigns(:contact).should equal(@contact)
      end

      it "should assign the found contact for the view" do
        do_put
        assigns(:contact).should equal(@contact)
      end

      it "should replace the contacts list" do
        do_put
        response.should have_rjs(:replace_html, "contact-list")
      end

    end
    
    describe "with failed update" do

      def do_put
        @person.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should not replace any content with RJS" do
        do_put
        response.should have_text(/alert/) 
        response.should have_text(/Validation failed/) 
      end

    end
  end

end
