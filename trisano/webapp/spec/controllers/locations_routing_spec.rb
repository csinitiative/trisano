require File.dirname(__FILE__) + '/../spec_helper'

describe LocationsController do
  describe "route generation" do

    it "should map { :controller => 'locations', :entity_id => 1, :action => 'index' } to /entities/1/locations" do
      route_for(:controller => "locations", :entity_id => 1, :action => "index").should == "/entities/1/locations"
    end
  
    it "should map { :controller => 'locations', :entity_id => 1, :action => 'new' } to /entities/1/locations/new" do
      route_for(:controller => "locations", :entity_id => 1, :action => "new").should == "/entities/1/locations/new"
    end
  
    it "should map { :controller => 'locations', :entity_id => 1, :action => 'show', :id => 1 } to /entities/1/locations/1" do
      route_for(:controller => "locations", :entity_id => 1, :action => "show", :id => 1).should == "/entities/1/locations/1"
    end
  
    it "should map { :controller => 'locations', :entity_id => 1, :action => 'edit', :id => 1 } to /entities/1/locations/1/edit" do
      route_for(:controller => "locations", :entity_id => 1, :action => "edit", :id => 1).should == "/entities/1/locations/1/edit"
    end
  
    it "should map { :controller => 'locations', :entity_id => 1, :action => 'update', :id => 1} to /entities/1/locations/1" do
      route_for(:controller => "locations", :entity_id => 1, :action => "update", :id => 1).should == "/entities/1/locations/1"
    end
  
    it "should map { :controller => 'locations', :entity_id => 1, :action => 'destroy', :id => 1} to /entities/1/locations/1" do
      route_for(:controller => "locations", :entity_id => 1, :action => "destroy", :id => 1).should == "/entities/1/locations/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'locations', action => 'index' } from GET /entities/1/locations" do
      params_from(:get, "/entities/1/locations").should == {:controller => "locations", :entity_id => "1", :action => "index"}
    end
  
    it "should generate params { :controller => 'locations', action => 'new' } from GET /entities/1/locations/new" do
      params_from(:get, "/entities/1/locations/new").should == {:controller => "locations", :entity_id => "1", :action => "new"}
    end
  
    it "should generate params { :controller => 'locations', action => 'create' } from POST /entities/1/locations" do
      params_from(:post, "/entities/1/locations").should == {:controller => "locations", :entity_id => "1", :action => "create"}
    end
  
    it "should generate params { :controller => 'locations', action => 'show', id => '1' } from GET /entities/1/locations/1" do
      params_from(:get, "/entities/1/locations/1").should == {:controller => "locations", :entity_id => "1", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'locations', action => 'edit', id => '1' } from GET /entities/1/locations/1;edit" do
      params_from(:get, "/entities/1/locations/1/edit").should == {:controller => "locations", :entity_id => "1", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'locations', action => 'update', id => '1' } from PUT /entities/1/locations/1" do
      params_from(:put, "/entities/1/locations/1").should == {:controller => "locations", :entity_id => "1", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'locations', action => 'destroy', id => '1' } from DELETE /entities/1/locations/1" do
      params_from(:delete, "/entities/1/locations/1").should == {:controller => "locations", :entity_id => "1", :action => "destroy", :id => "1"}
    end
  end
end
