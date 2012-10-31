# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

require 'spec_helper'

describe MorbidityEventsController do
  before do
    create_user
  end

  { :get => [:edit, :show],
    :post => [:soft_delete],
    :put => [:update],
    :delete => [:destroy] }.each do |meth, actions|
    actions.each do |action|
      it "should guard access to sensitive events: #{action}" do
        @event = Factory(:morbidity_event)
        Event.stubs(:find).returns(@event)
        @event.stubs(:sensitive?).returns(true)
        @user.stubs(:can_update?).returns(true)
        @user.stubs(:can_view?).returns(true)
        @user.stubs(:can_access_sensitive_diseases?).returns(false)
        send(meth, action, :id => @event)
        response.code.should == "403"
      end
    end
  end
    
  describe "handling GET /events" do

    before(:each) do
      @event = Factory(:morbidity_event)
      MorbidityEvent.expects(:find_all_for_filtered_view).with(kind_of(Hash)).returns([@event])
      @user.stubs(:can_view?).returns(true)
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
      do_get
    end

    it "should assign the found events for the view" do
      do_get
      assigns[:events].should == [@event]
    end

    it "should load event queues" do
      do_get
      assigns[:event_queues].should == []
    end

 end

  describe "handling GET /events/1 with view entitlement" do

    before(:each) do
      @event = Factory(:morbidity_event)
      Event.stubs(:find).returns(@event)
      @user.stubs(:can_view?).with(@event).returns(true)
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
      Event.expects(:find).once().with("75").returns(@event)
      do_get
    end

    it "should assign the found event for the view" do
      do_get
      assigns[:event].should equal(@event)
    end
  end

  describe "handling GETting a real event of the wrong type" do

    before(:each) do
      @event = Factory(:contact_event)
      Event.stubs(:find).returns(@event)
      @user.stubs(:can_view?).with(@event).returns(true)
    end

    def do_get
      get :show, :id => "75"
    end

    it "should return a 404" do
      do_get
      response.response_code.should == 404
    end

    it "should render the public 404 page" do
      do_get
      response.should render_template "shared/_missing_event"
    end

  end

  describe "handling GET /events/1 without view entitlement" do

    before(:each) do
      @event = mock_event
      @event.stubs(:add_note)
      Event.stubs(:find).returns(@event)
      @user.stubs(:is_entitled_to_in?).returns(false)
      @event.stubs(:read_attribute).returns('MorbidityEvent')
    end

    def do_get
      get :show, :id => "75"
    end

    it "should find the event requested" do
      Event.expects(:find).with("75").returns(@event)
      do_get
    end

    it "should redirect to the new event access view" do
      do_get
      response.should redirect_to(new_event_access_record_url(@event))
    end

  end

  describe "handling GET /events/new" do

    before(:each) do
      @event = mock_event
      MorbidityEvent.stubs(:new).returns(@event)
      @user.stubs(:is_entitled_to?).with(:create_event).returns(true)
      @event.stubs(:read_attribute).returns('MorbidityEvent')
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
      MorbidityEvent.expects(:new).returns(@event)
      do_get
    end

    it "should not save the new event" do
      @event.expects(:save).never
      do_get
    end

    it "should assign the new event for the view" do
      do_get
      assigns[:event].should equal(@event)
    end
  end

  describe "handling GET /events/1/edit with update entitlement" do

    before(:each) do
      @event = Factory(:morbidity_event)
      @form_reference = Factory.build(:form_reference)
      @form = Factory.build(:form)

      Event.stubs(:find).returns(@event)
      @event.stubs(:get_investigation_forms).returns([@form])
      @user.stubs(:can_update?).with(@event).returns(true)
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

    it "should assign the found MorbidityEvent for the view" do
      do_get
      assigns[:event].should equal(@event)
    end
  end

  describe "handling JURISDICTION requests /events/1/jurisdiction" do
    before(:each) do
      @user.stubs(:is_entitled_to_in?).with(:route_event_to_any_lhd, 1).returns(true)
      @user.stubs(:can_create?).returns(true)
      @user.stubs(:is_entitled_to_in?).returns(true)

      @jurisdiction = Factory.build(:jurisdiction)
      @jurisdiction.stubs(:secondary_entity_id).returns(1)

      @primary_jurisdiction = Factory.build(:place)
      @primary_jurisdiction.stubs(:is_unassigned_jurisdiction?).returns(false)

      @event = Factory.build(:morbidity_event)
      @event.stubs(:jurisdiction).returns(@jurisdiction)
      @event.stubs(:update_attribute).returns(true)
      @event.stubs(:primary_jurisdiction).returns(@primary_jurisdiction)
    end

    describe "with successful routing" do
      def do_route_event
        Event.expects(:find).returns(@event)
        request.env['HTTP_REFERER'] = "/some_path"
        @event.expects(:assign_to_lhd)
        @event.expects(:save!)
        post :jurisdiction, :id => "1", :routing => { :jurisdiction_id => "2" }
      end

      it "should find the event requested" do
        do_route_event
      end

      it "should redirect to the where it was called from" do
        do_route_event
        response.should redirect_to("http://test.host/some_path")
      end

      describe "setting the status field" do
        describe "with a new route" do
          it "should change status to ASGD-LHD" do
            do_route_event
          end
        end

        describe "With an existing route" do
          it "should not change status" do
            @jurisdiction.stubs(:secondary_entity_id).returns(2)
            @event.expects(:update_attribute).never
            do_route_event
          end
        end
      end

      describe "with secondary_ids too" do
        it "should pass IDs into event#route_to_jurisdiction" do
          Event.expects(:find).returns(@event)
          @event.expects(:assign_to_lhd)
          @event.expects(:save!)
          request.env['HTTP_REFERER'] = "/some_path"
          post :jurisdiction, :id => "1", :routing => { :jurisdiction_id => "2", :note => "" }, :secondary_jurisdiction_ids => ["3", "4"]
        end
      end
    end

  end

  describe "handling STATE actions /events/1/state" do
    def set_up_mocks
      @user.stubs(:is_entitled_to_in?).with(:a_privilege, 1).returns(true)
      @user.stubs(:jurisdiction_ids_for_privilege).with(:view_event).returns([1])

      @jurisdiction = Factory.build(:jurisdiction)
      @jurisdiction.stubs(:secondary_entity_id).returns(1)

      @event = Factory.build(:morbidity_event)
      @event.stubs(:jurisdiction).returns(@jurisdiction)
      @event.stubs(:update_attributes).returns(true)
      @event.stubs(:attributes=).returns(1)
      @event.stubs(:investigator_id=).returns(@user.id)
      @event.stubs(:investigation_started_date=)
      @event.stubs(:add_note)
      MorbidityEvent.stubs(:find).returns(@event)
      ExternalCode.stubs(:event_code_str).returns("A_PRIV")
    end

    describe "with successful state change" do
      before(:each) do
        set_up_mocks
      end

      def do_change_state
        Event.expects(:find).with("1").returns(@event)
        request.env['HTTP_REFERER'] = "/some_path"
        @event.expects(:a_status)
        @event.expects(:save).returns(true)
        post :state, :id => "1", :morbidity_event => {:workflow_action=> 'a_status'}
      end

      it "should find the event requested" do
        do_change_state
      end

      it "should redirect to the where it was called from" do
        do_change_state
        response.should redirect_to("http://test.host/some_path")
      end
    end

    describe "with bad state argument" do

      def do_change_state
        event = Factory.build(:morbidity_event)
        event.expects(:halted?).returns true
        Event.expects(:find).with("1").returns(event)

        request.env['HTTP_REFERER'] = "/some_path"
        post :state, :id => "1", :morbidity_event => {:workflow_action => 'a_status'}
      end

      it "should respond with a 403" do
        do_change_state
        response.code.should == "403"
      end
    end

    describe "with insufficent privileges" do
      def do_change_state
        event = Factory.build(:morbidity_event)
        event.expects(:halted?).returns true
        Event.expects(:find).returns(event)

        post :state, :id => "1", :morbidity_event => {:event_status => 'a_status'}
      end

      it "should respond with a 403" do
        do_change_state
        response.code.should == "403"
      end
    end

  end

  describe "handling successful POST /cmrs/1/soft_delete with update entitlement" do

    before(:each) do
      @event = Factory(:morbidity_event)
      Event.stubs(:find).returns(@event)
      @user.stubs(:can_update?).returns(true)
      @event.stubs(:add_note).returns(true)
    end

    def do_post
      request.env['HTTP_REFERER'] = "/some_path"
      post :soft_delete, :id => "1"
    end

    it "should redirect to where the user came from" do
      @event.expects(:soft_delete).returns(true)
      do_post
      response.should redirect_to("http://test.host/some_path")
    end

    it "should set the flash notice to a success message" do
      @event.expects(:soft_delete).returns(true)
      do_post
      flash[:notice].should == "The event was successfully marked as deleted."
    end
  end

  describe "handling failed POST /cmrs/1/soft_delete with update entitlement" do

    before(:each) do
      @event = Factory(:morbidity_event)
      Event.stubs(:find).returns(@event)
      @user.stubs(:can_update?).returns(true)
      @event.stubs(:add_note).returns(true)
    end

    def do_post
      request.env['HTTP_REFERER'] = "/some_path"
      post :soft_delete, :id => "1"
    end

    it "should redirect to where the user came from" do
      @event.expects(:soft_delete).returns(false)
      do_post
      response.should redirect_to("http://test.host/some_path")
    end

    it "should set the flash error to an error message" do
      @event.expects(:soft_delete).returns(false)
      do_post
      flash[:error].should eql("An error occurred marking the event as deleted.")
    end

    it "should not add a note" do
      @event.expects(:soft_delete).returns(false)
      @event.expects(:add_note).never
      do_post
    end
  end

  describe "handling POST /cmrs/1/soft_delete without update entitlement" do

    before(:each) do
      @event = Factory(:morbidity_event)
      Event.stubs(:find).returns(@event)
      @user.stubs(:is_entitled_to_in?).returns(false)
      @event.stubs(:add_note).returns(true)
    end

    def do_post
      request.env['HTTP_REFERER'] = "/some_path"
      post :soft_delete, :id => "1"
    end

    it "should be be a 403" do
      do_post
      response.response_code.should == 403
    end

    it "should not add a note" do
      @event.expects(:add_note).never
      do_post
    end
  end

  describe "POST /cmrs" do
    before do
      @event_attributes = { "first_reported_PH_date" => Date.yesterday }
      @event_attributes["interested_party_attributes"] = {
        "person_entity_attributes" => {
          "person_attributes" => {
            "last_name" => "Lester"
          }
        }
      }
      @disease = Factory.create(:disease)
      @event_attributes["disease_event_attributes"] = { "disease_id" => @disease.id }
      @jurisdiction = create_jurisdiction_entity
      @event_attributes["jurisdiction_attributes"] = { "secondary_entity_id" => @jurisdiction.id }
    end

    def do_post(event_attributes)
      post :create, :morbidity_event => event_attributes
    end

    it "should forbid users from creating events if they don't have create privileges" do
      @user.stubs(:can_create?).returns(false)
      do_post(@event_attributes)
      response.code.should == "403"
    end

    it "should forbid users from creating sensitve events if they don't have senstive disease privileges" do
      @disease.update_attribute("sensitive", true)
      @user.stubs(:can_create?).returns(true)
      @user.stubs(:can_access_sensitive_diseases?).returns(false)
      do_post(@event_attributes)
      response.code.should == "403"
    end
  end

  describe "PUT cmrs/1" do
    before do
      @cmr = Factory.create(:morbidity_event)
      @promoted_event = Factory.create(:contact_event, :parent_event => @cmr)
      User.current_user.stubs(:can_update?).returns(true)
      @promoted_event.promote_to_morbidity_event
    end

    context "with a redirect option" do
      it "redirects to specified url if 'Save & Exit' clicked" do
        put(:update, {
              :id => @promoted_event.id,
              :redirect_to => '/sample/url',
              :morbidity_event => {
                :first_reported_PH_date => Date.yesterday
              }
            })
        response.should redirect_to('/sample/url')
      end

      it "does not redirect if 'Save & Continue' clicked" do
        put(:update, {
              :id => @promoted_event.id,
              :redirect_to => '/sample/url',
              :return => 1,
              :morbidity_event => {
                :first_reported_PH_date => Date.yesterday
              }
            })
        response.should redirect_to(edit_cmr_url(@promoted_event))
      end
    end

    it "should always update the event's last modified date, even if the event data doesn't change" do
      lambda do
        sleep 1
        put :update, :id => @cmr.id
        @cmr.reload
      end.should change(@cmr, :updated_at)
    end
  end

  describe "xml api" do
    before do
      @event = Factory.create(:morbidity_event)
      @user = Factory(:user)
      @user.stubs(:can_view?).returns(true)
      @user.stubs(:can_update?).returns(true)
      @user.stubs(:can_create?).returns(true)
      User.stubs(:current_user).returns(@user)
    end

    it "returns xml for the event" do
      request.env['HTTP_ACCEPT'] = 'application/xml'
      get :show, :id => @event
      response.should be_success
      response.content_type.should == 'application/xml'
    end

    context "for creating events" do

      before do
        @xml = <<-XML
          <morbidity-event>
          <first-reported-PH-date>#{Date.today.xmlschema}</first-reported-PH-date>
          <interested-party-attributes>
          <person-entity-attributes>
          <race_ids>#{ExternalCode.find_by_code_description_and_code_name('White', 'race').id}</race_ids>
          <race_ids>#{ExternalCode.find_by_code_description_and_code_name('Asian', 'race').id}</race_ids>
          <person-attributes><last-name>Smoker</last-name></person-attributes>
          </person-entity-attributes></interested-party-attributes>
          <jurisdiction-attributes>
          <secondary-entity-id>#{create_jurisdiction_entity.id}</secondary-entity-id>
          </jurisdiction-attributes>
          </morbidity-event>
        XML
      end

      it "can create events for patients w/ multiple races" do
        User.stubs(:find_by_uid).returns(@user)
        @user.stubs(:can_create?).returns(true)
        @event.stubs(:add_note).returns(true)
        request.env['HTTP_ACCEPT'] = 'application/xml'
        post :create, Hash.from_xml(@xml)
        response.code.should == "201"
        response.headers['Location'].should =~ %r{/cmrs/\d+}
        assigns[:event].should_not be_nil
        assigns[:event].safe_call_chain(*%w(interested_party person_entity race_ids size)).should == 2
      end
    end
  end
end
