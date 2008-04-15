require File.dirname(__FILE__) + '/../spec_helper'

describe GroupsController do
  describe "route generation" do

    it "should map { :controller => 'groups', :action => 'index' } to /groups" do
      route_for(:controller => "groups", :action => "index").should == "/groups"
    end
  
    it "should map { :controller => 'groups', :action => 'new' } to /groups/new" do
      route_for(:controller => "groups", :action => "new").should == "/groups/new"
    end
  
    it "should map { :controller => 'groups', :action => 'show', :id => 1 } to /groups/1" do
      route_for(:controller => "groups", :action => "show", :id => 1).should == "/groups/1"
    end
  
    it "should map { :controller => 'groups', :action => 'edit', :id => 1 } to /groups/1/edit" do
      route_for(:controller => "groups", :action => "edit", :id => 1).should == "/groups/1/edit"
    end
  
    it "should map { :controller => 'groups', :action => 'update', :id => 1} to /groups/1" do
      route_for(:controller => "groups", :action => "update", :id => 1).should == "/groups/1"
    end
  
    it "should map { :controller => 'groups', :action => 'destroy', :id => 1} to /groups/1" do
      route_for(:controller => "groups", :action => "destroy", :id => 1).should == "/groups/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'groups', action => 'index' } from GET /groups" do
      params_from(:get, "/groups").should == {:controller => "groups", :action => "index"}
    end
  
    it "should generate params { :controller => 'groups', action => 'new' } from GET /groups/new" do
      params_from(:get, "/groups/new").should == {:controller => "groups", :action => "new"}
    end
  
    it "should generate params { :controller => 'groups', action => 'create' } from POST /groups" do
      params_from(:post, "/groups").should == {:controller => "groups", :action => "create"}
    end
  
    it "should generate params { :controller => 'groups', action => 'show', id => '1' } from GET /groups/1" do
      params_from(:get, "/groups/1").should == {:controller => "groups", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'groups', action => 'edit', id => '1' } from GET /groups/1;edit" do
      params_from(:get, "/groups/1/edit").should == {:controller => "groups", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'groups', action => 'update', id => '1' } from PUT /groups/1" do
      params_from(:put, "/groups/1").should == {:controller => "groups", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'groups', action => 'destroy', id => '1' } from DELETE /groups/1" do
      params_from(:delete, "/groups/1").should == {:controller => "groups", :action => "destroy", :id => "1"}
    end
  end
end