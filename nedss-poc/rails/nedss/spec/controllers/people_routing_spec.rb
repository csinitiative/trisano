require File.dirname(__FILE__) + '/../spec_helper'

describe PeopleController do
  describe "route generation" do

    it "should map { :controller => 'people', :action => 'index' } to /people" do
      route_for(:controller => "people", :action => "index").should == "/people"
    end
  
    it "should map { :controller => 'people', :action => 'new' } to /people/new" do
      route_for(:controller => "people", :action => "new").should == "/people/new"
    end
  
    it "should map { :controller => 'people', :action => 'show', :id => 1 } to /people/1" do
      route_for(:controller => "people", :action => "show", :id => 1).should == "/people/1"
    end
  
    it "should map { :controller => 'people', :action => 'edit', :id => 1 } to /people/1/edit" do
      route_for(:controller => "people", :action => "edit", :id => 1).should == "/people/1/edit"
    end
  
    it "should map { :controller => 'people', :action => 'update', :id => 1} to /people/1" do
      route_for(:controller => "people", :action => "update", :id => 1).should == "/people/1"
    end
  
    it "should map { :controller => 'people', :action => 'destroy', :id => 1} to /people/1" do
      route_for(:controller => "people", :action => "destroy", :id => 1).should == "/people/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'people', action => 'index' } from GET /people" do
      params_from(:get, "/people").should == {:controller => "people", :action => "index"}
    end
  
    it "should generate params { :controller => 'people', action => 'new' } from GET /people/new" do
      params_from(:get, "/people/new").should == {:controller => "people", :action => "new"}
    end
  
    it "should generate params { :controller => 'people', action => 'create' } from POST /people" do
      params_from(:post, "/people").should == {:controller => "people", :action => "create"}
    end
  
    it "should generate params { :controller => 'people', action => 'show', id => '1' } from GET /people/1" do
      params_from(:get, "/people/1").should == {:controller => "people", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'people', action => 'edit', id => '1' } from GET /people/1;edit" do
      params_from(:get, "/people/1/edit").should == {:controller => "people", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'people', action => 'update', id => '1' } from PUT /people/1" do
      params_from(:put, "/people/1").should == {:controller => "people", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'people', action => 'destroy', id => '1' } from DELETE /people/1" do
      params_from(:delete, "/people/1").should == {:controller => "people", :action => "destroy", :id => "1"}
    end
  end
end