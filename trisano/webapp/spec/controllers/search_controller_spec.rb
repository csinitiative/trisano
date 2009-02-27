# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

shared_examples_for "search cmrs with parameters" do
  
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
      @person.stub!(:entity_id).and_return(1)
      @person_hash = {:person => @person, :event_type => "No associated event", :event_id => nil, :deleted_at => nil}
      Person.stub!(:find_by_ts).and_return([@person])
      Event.stub!(:find).and_return(nil)
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
      assigns[:people].should == ([@person_hash])
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

    it_should_behave_like "search cmrs with parameters"
  
  end
  
  describe "handling GET /search/cmrs with params as csv" do
    
    before(:each) do
      mock_user
      @event = mock_model(Event)
      Event.stub!(:find_by_criteria).and_return([@event])
      
      @diseases = mock_model(Disease)
      Disease.stub!(:find).and_return([@diseases])
    end

    def do_get
      get :cmrs, :disease => 2, :format => 'csv'
    end

    it_should_behave_like "search cmrs with parameters"

    it "should return csv mime type" do
      do_get
      response.content_type.should match(/^text\/csv/)
    end

  end
  
end
