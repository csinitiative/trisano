require File.dirname(__FILE__) + '/../spec_helper'

describe EthnicitiesController do
  describe "route generation" do

    it "should map { :controller => 'ethnicities', :action => 'index' } to /ethnicities" do
      route_for(:controller => "ethnicities", :action => "index").should == "/ethnicities"
    end
  
    it "should map { :controller => 'ethnicities', :action => 'new' } to /ethnicities/new" do
      route_for(:controller => "ethnicities", :action => "new").should == "/ethnicities/new"
    end
  
    it "should map { :controller => 'ethnicities', :action => 'show', :id => 1 } to /ethnicities/1" do
      route_for(:controller => "ethnicities", :action => "show", :id => 1).should == "/ethnicities/1"
    end
  
    it "should map { :controller => 'ethnicities', :action => 'edit', :id => 1 } to /ethnicities/1/edit" do
      route_for(:controller => "ethnicities", :action => "edit", :id => 1).should == "/ethnicities/1/edit"
    end
  
    it "should map { :controller => 'ethnicities', :action => 'update', :id => 1} to /ethnicities/1" do
      route_for(:controller => "ethnicities", :action => "update", :id => 1).should == "/ethnicities/1"
    end
  
    it "should map { :controller => 'ethnicities', :action => 'destroy', :id => 1} to /ethnicities/1" do
      route_for(:controller => "ethnicities", :action => "destroy", :id => 1).should == "/ethnicities/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'ethnicities', action => 'index' } from GET /ethnicities" do
      params_from(:get, "/ethnicities").should == {:controller => "ethnicities", :action => "index"}
    end
  
    it "should generate params { :controller => 'ethnicities', action => 'new' } from GET /ethnicities/new" do
      params_from(:get, "/ethnicities/new").should == {:controller => "ethnicities", :action => "new"}
    end
  
    it "should generate params { :controller => 'ethnicities', action => 'create' } from POST /ethnicities" do
      params_from(:post, "/ethnicities").should == {:controller => "ethnicities", :action => "create"}
    end
  
    it "should generate params { :controller => 'ethnicities', action => 'show', id => '1' } from GET /ethnicities/1" do
      params_from(:get, "/ethnicities/1").should == {:controller => "ethnicities", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'ethnicities', action => 'edit', id => '1' } from GET /ethnicities/1;edit" do
      params_from(:get, "/ethnicities/1/edit").should == {:controller => "ethnicities", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'ethnicities', action => 'update', id => '1' } from PUT /ethnicities/1" do
      params_from(:put, "/ethnicities/1").should == {:controller => "ethnicities", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'ethnicities', action => 'destroy', id => '1' } from DELETE /ethnicities/1" do
      params_from(:delete, "/ethnicities/1").should == {:controller => "ethnicities", :action => "destroy", :id => "1"}
    end
  end
end