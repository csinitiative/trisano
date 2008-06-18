require File.dirname(__FILE__) + '/../spec_helper'

describe CliniciansController do
  
  describe "handling GET /clinicians/new" do

    before(:each) do
      mock_user
      @event = mock_event
      @clinician = mock_model(Entity)
      Event.stub!(:find).and_return(@event)
      Entity.stub!(:new).and_return(@clinician)
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
  
    it "should create an new clinician" do
      Entity.should_receive(:new).and_return(@clinician)
      do_get
    end
  
    it "should not save the new clinician" do
      @clinician.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new clinician for the view" do
      do_get
      assigns[:clinician].should equal(@clinician)
    end
  end

  describe "handling GET /clinicians/1/edit" do

    before(:each) do
      mock_user
      @event = mock_event
      @clinician = mock_model(Participation)
      @clinicians = [@clinician]
      @clinicians.stub!(:find).and_return(@clinician)
      Event.stub!(:find).and_return(@event)
      @event.stub!(:clinicians).and_return(@clinicians)
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
  
    it "should assign the found Clinician for the view" do
      do_get
      assigns[:clinician].should equal(@clinician)
    end
  end

  describe "handling POST /clinicians" do

    before(:each) do
      mock_user
      @event = mock_event
      @clinician = mock_model(Participation, :to_param => "1")
      @person = mock_person_entity
      @errors.stub!(:full_messages).and_return([])
      @clinician.stub!(:active_secondary_entity).and_return(@person)
      @clinicians = []
      Event.stub!(:find).and_return(@event)
      Participation.stub!(:new).and_return(@clinician)
      @event.stub!(:clinicians).and_return(@clinicians)
    end
    
    describe "with successful save" do
  
      def do_post
        @clinicians.should_receive("<<").and_return(true)
        post :create, {:clinician => {}, :cmr_id => "1"}
      end
  
      it "should create a new clinician" do
        Participation.should_receive(:new).and_return(@clinician)
        do_post
      end

      it "should replace the clinicians list" do
        do_post
        # Debt: See about getting this to be more specific
        response.should have_rjs
      end
    end
    
    describe "with failed save" do

      def do_post
        @clinicians.should_receive("<<").and_return(nil)
        
        post :create, :clinician => {}
      end
  
      it "should send down some RJS with an alert" do
        pending "Failing on the full_messages call"
        do_post
        # Debt: See about getting this to be more specific
        response.should have_rjs
      end
      
    end
  end

  describe "handling PUT /clinicians/1" do

    before(:each) do
      mock_user
      @event = mock_event
      @clinician = mock_model(Participation, :to_param => "1")
      @person = mock_person_entity
      @clinician.stub!(:active_secondary_entity).and_return(@person)
      @clinicians = [@clinician]
      @clinicians.stub!(:find).and_return(@clinician)
      Event.stub!(:find).and_return(@event)
      Participation.stub!(:new).and_return(@clinician)
      @event.stub!(:clinicians).and_return(@clinicians)
    end
    
    describe "with successful update" do

      def do_put
        @person.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should update the found clinician" do
        do_put
        assigns(:clinician).should equal(@clinician)
      end

      it "should assign the found clinician for the view" do
        do_put
        assigns(:clinician).should equal(@clinician)
      end

      it "should replace the clinicians list" do
        do_put
        # Debt: See about getting this to be more specific
        response.should have_rjs
      end

    end
    
    describe "with failed update" do

      def do_put
        @person.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should send down some RJS with an alert" do
        pending "Failing on the full_messages call"
        do_put
        # Debt: See about getting this to be more specific
        response.should have_rjs
      end

    end
  end

end