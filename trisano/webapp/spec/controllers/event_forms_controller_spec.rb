# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

require File.dirname(__FILE__) + '/../spec_helper'

describe EventFormsController do
  before(:each) do
    mock_user
    @event = mock_model(Event, :to_param => "1")
    @event.stub!(:get_investigation_forms).and_return(nil)
    Event.stub!(:find).and_return(@event)
  end

  describe "handling GET /events/1/forms" do

    before(:each) do
      @form = mock_model(Form)
      Form.stub!(:find).and_return([@form])

      @form_reference = mock_model(FormReference)
      @form_reference.stub!(:form).and_return(@form)
      @event.stub!(:form_references).and_return([@form_reference])
    end
  
    def do_get
      get :index, :event_id => "1"
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
  
    it "should find all event_forms" do
      Form.should_receive(:find).once.and_return([@form])
      do_get
    end
  
    it "should assign the found event_forms for the view" do
      do_get
      assigns[:event].should == @event
      assigns[:forms_available].should == [@form]
      assigns[:forms_in_use].should == [@form]
    end

    # Debt: Not working for some reason
    # it "should 404 if event not found" do
    #   Event.stub!(:find).and_raise(Exception)
    #   do_get
    #   response.should render_template("#{RAILS_ROOT}/public/404.html")
    #   response.headers["Status"].should == "404 Not Found"
    # end

  end

  describe "handling POST /events/1/forms" do

    before(:each) do
      @form_reference = mock_model(FormReference)
      @form_reference.stub!(:id).and_return(1)
      @event.stub!(:form_references).and_return([@form_reference])

      @form = mock_model(Form)
      Form.stub!(:find).and_return(@form)
    end
    
    describe "with bad or duplicative parameters" do
  
    # Debt: Not working for some reason
    #  it "should 422 if form not found" do
    #    Form.stub!(:find).and_raise
    #    post :create, :forms_to_add => [99], :event_id => "1"
    #    response.should render_template("#{RAILS_ROOT}/public/422.html")
    #    response.response_code.should == 422
    #  end

      it "should do nothing if no form references are pased in" do
        post :create, :event_id => "1"
        flash[:error].should == 'No forms were selected for addition to this event.'
        flash[:notice].should be_nil
      end

      it "should do nothing if passed in form reference is already associated with event" do
        @event.form_references.should_not_receive(:create)
        post :create, :forms_to_add => [1], :event_id => "1"
        flash[:error].should be_nil
      end

      it "should add one new form reference to event if passed in 1 new and 1 existing reference" do
        form_references_proxy = mock("form referneces proxy")
        form_references_proxy.stub!(:map).and_return([1])
        @event.stub!(:form_references).and_return(form_references_proxy)
        @event.form_references.should_receive(:create).once().and_return(true)

        post :create, :forms_to_add => [1, 2], :event_id => "1"
        flash[:error].should be_nil
        flash[:notice].should == 'The list of forms in use was successfully updated.'
      end

      it "should add two new form references to event if passed in 2 new references" do 
        form_references_proxy = mock("form referneces proxy")
        form_references_proxy.stub!(:map).and_return([1])
        @event.stub!(:form_references).and_return(form_references_proxy)
        @event.form_references.should_receive(:create).twice().and_return(true)

        post :create, :forms_to_add => [2, 3], :event_id => "1"
        flash[:error].should be_nil
        flash[:notice].should == 'The list of forms in use was successfully updated.'
      end

      it "should redirect to the event forms form" do
        post :create, :event_id => "1"
        response.should redirect_to(event_forms_path("1"))
      end
      
    end

    describe "with failed save" do

      it "should flash an error and redirect to the event forms form" do
        form_references_proxy = mock("form referneces proxy")
        form_references_proxy.stub!(:map).and_return([1])
        @event.stub!(:form_references).and_return(form_references_proxy)
        @event.form_references.should_receive(:create).and_return(false)

        post :create, :forms_to_add => [3], :event_id => "1"
        flash[:error].should == 'There was an error during processing.'
        flash[:notice].should be_nil
      end
      
    end

  end

end
