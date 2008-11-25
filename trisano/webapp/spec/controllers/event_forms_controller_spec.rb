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
    Event.stub!(:find).and_return(@event)
  end

  describe "handling GET /events/1/forms" do

    before(:each) do
      @form_1 = mock_model(Form)
      @form_2 = mock_model(Form)
      Form.stub!(:find).and_return([@form_1])

      @form_reference = mock_model(FormReference)
      @form_reference.stub!(:form).and_return(@form_2)
      @event.stub!(:form_references).and_return([@form_reference])
      @event.stub!(:get_investigation_forms).and_return(nil)
    end
  
    def do_get
      get :index, :event_id => "1"
    end
  
    it "should load up viable forms" do
      @event.should_receive(:get_investigation_forms).once
      do_get
    end

    it "should find all forms" do
      @event.should_receive(:form_references).and_return([@form_reference])
      @form_reference.should_receive(:form).and_return(@form_2)
      Form.should_receive(:find).once.and_return([@form_1])
      do_get
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
  
  
    it "should assign the found event_forms for the view" do
      do_get
      assigns[:event].should == @event
      assigns[:forms_available].should == [@form_1]
      assigns[:forms_in_use].should == [@form_2]
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
#      @form_reference = mock_model(FormReference)
#      @form_reference.stub!(:id).and_return(1)
#      @event.stub!(:form_references).and_return([@form_reference])
#
#      @form = mock_model(Form)
#      Form.stub!(:find).and_return(@form)
    end
    
    describe "with bad or duplicative parameters" do
  
      it "should do nothing if no form references are pased in" do
        post :create, :event_id => "1"
        @event.should_not_receive(:add_forms)
        flash[:error].should == 'No forms were selected for addition to this event.'
        flash[:notice].should be_nil
      end

      it "should call add_forms once to save form references" do
        @event.should_receive(:add_forms).once()
        post :create, :forms_to_add => [1, 2], :event_id => "1"
        flash[:error].should be_nil
        flash[:notice].should == 'The list of forms in use was successfully updated.'
      end

      it "should send a 422 if add forms raises a RecordNot Found error." do
        @event.should_receive(:add_forms).and_raise(ActiveRecord::RecordNotFound)
        post :create, :forms_to_add => [2, 3], :event_id => "1"
        response.should render_template("#{RAILS_ROOT}/public/422.html")
        response.response_code.should == 422
      end

      it "should send a 500 if anything else goes wrong." do
        @event.should_receive(:add_forms).and_raise(RuntimeError)
        post :create, :forms_to_add => [2, 3], :event_id => "1"
        response.should render_template("#{RAILS_ROOT}/public/500.html")
        response.response_code.should == 500
      end

      it "should redirect to the event forms form otherwise" do
        post :create, :event_id => "1"
        response.should redirect_to(event_forms_path("1"))
      end
      
    end

  end

end
