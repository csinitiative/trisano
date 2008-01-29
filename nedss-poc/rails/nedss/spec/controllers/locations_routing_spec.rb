require File.dirname(__FILE__) + '/../spec_helper'

describe LocationsController do
  describe "route generation" do

    it "should map { :controller => 'locations', :person_id => 1, :action => 'index' } to /people/1/locations" do
      route_for(:controller => "locations", :person_id => 1, :action => "index").should == "/people/1/locations"
    end
  
    it "should map { :controller => 'locations', :person_id => 1, :action => 'new' } to /people/1/locations/new" do
      route_for(:controller => "locations", :person_id => 1, :action => "new").should == "/people/1/locations/new"
    end
  
    it "should map { :controller => 'locations', :person_id => 1, :action => 'show', :id => 1 } to /people/1/locations/1" do
      route_for(:controller => "locations", :person_id => 1, :action => "show", :id => 1).should == "/people/1/locations/1"
    end
  
    it "should map { :controller => 'locations', :person_id => 1, :action => 'edit', :id => 1 } to /people/1/locations/1/edit" do
      route_for(:controller => "locations", :person_id => 1, :action => "edit", :id => 1).should == "/people/1/locations/1/edit"
    end
  
    it "should map { :controller => 'locations', :person_id => 1, :action => 'update', :id => 1} to /people/1/locations/1" do
      route_for(:controller => "locations", :person_id => 1, :action => "update", :id => 1).should == "/people/1/locations/1"
    end
  
    it "should map { :controller => 'locations', :person_id => 1, :action => 'destroy', :id => 1} to /people/1/locations/1" do
      route_for(:controller => "locations", :person_id => 1, :action => "destroy", :id => 1).should == "/people/1/locations/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'locations', action => 'index' } from GET /people/1/locations" do
      params_from(:get, "/people/1/locations").should == {:controller => "locations", :person_id => "1", :action => "index"}
    end
  
    it "should generate params { :controller => 'locations', action => 'new' } from GET /people/1/locations/new" do
      params_from(:get, "/people/1/locations/new").should == {:controller => "locations", :person_id => "1", :action => "new"}
    end
  
    it "should generate params { :controller => 'locations', action => 'create' } from POST /people/1/locations" do
      params_from(:post, "/people/1/locations").should == {:controller => "locations", :person_id => "1", :action => "create"}
    end
  
    it "should generate params { :controller => 'locations', action => 'show', id => '1' } from GET /people/1/locations/1" do
      params_from(:get, "/people/1/locations/1").should == {:controller => "locations", :person_id => "1", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'locations', action => 'edit', id => '1' } from GET /people/1/locations/1;edit" do
      params_from(:get, "/people/1/locations/1/edit").should == {:controller => "locations", :person_id => "1", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'locations', action => 'update', id => '1' } from PUT /people/1/locations/1" do
      params_from(:put, "/people/1/locations/1").should == {:controller => "locations", :person_id => "1", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'locations', action => 'destroy', id => '1' } from DELETE /people/1/locations/1" do
      params_from(:delete, "/people/1/locations/1").should == {:controller => "locations", :person_id => "1", :action => "destroy", :id => "1"}
    end
  end
end
