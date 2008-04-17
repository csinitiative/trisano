require File.dirname(__FILE__) + '/../spec_helper'

describe CmrsController do
  describe "route generation" do

    it "should map { :controller => 'cmrs', :action => 'index' } to /cmrs" do
      route_for(:controller => "cmrs", :action => "index").should == "/cmrs"
    end
  
    it "should map { :controller => 'cmrs', :action => 'new' } to /cmrs/new" do
      route_for(:controller => "cmrs", :action => "new").should == "/cmrs/new"
    end
  
    it "should map { :controller => 'cmrs', :action => 'show', :id => 1 } to /cmrs/1" do
      route_for(:controller => "cmrs", :action => "show", :id => 1).should == "/cmrs/1"
    end
  
    it "should map { :controller => 'cmrs', :action => 'edit', :id => 1 } to /cmrs/1/edit" do
      route_for(:controller => "cmrs", :action => "edit", :id => 1).should == "/cmrs/1/edit"
    end
  
    it "should map { :controller => 'cmrs', :action => 'update', :id => 1} to /cmrs/1" do
      route_for(:controller => "cmrs", :action => "update", :id => 1).should == "/cmrs/1"
    end
  
    it "should map { :controller => 'cmrs', :action => 'destroy', :id => 1} to /cmrs/1" do
      route_for(:controller => "cmrs", :action => "destroy", :id => 1).should == "/cmrs/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'cmrs', action => 'index' } from GET /cmrs" do
      params_from(:get, "/cmrs").should == {:controller => "cmrs", :action => "index"}
    end
  
    it "should generate params { :controller => 'cmrs', action => 'new' } from GET /cmrs/new" do
      params_from(:get, "/cmrs/new").should == {:controller => "cmrs", :action => "new"}
    end
  
    it "should generate params { :controller => 'cmrs', action => 'create' } from POST /cmrs" do
      params_from(:post, "/cmrs").should == {:controller => "cmrs", :action => "create"}
    end
  
    it "should generate params { :controller => 'cmrs', action => 'show', id => '1' } from GET /cmrs/1" do
      params_from(:get, "/cmrs/1").should == {:controller => "cmrs", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'cmrs', action => 'edit', id => '1' } from GET /cmrs/1;edit" do
      params_from(:get, "/cmrs/1/edit").should == {:controller => "cmrs", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'cmrs', action => 'update', id => '1' } from PUT /cmrs/1" do
      params_from(:put, "/cmrs/1").should == {:controller => "cmrs", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'cmrs', action => 'destroy', id => '1' } from DELETE /cmrs/1" do
      params_from(:delete, "/cmrs/1").should == {:controller => "cmrs", :action => "destroy", :id => "1"}
    end
  end
end