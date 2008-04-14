require File.dirname(__FILE__) + '/../spec_helper'

describe FormsController do
  describe "route generation" do

    it "should map { :controller => 'forms', :action => 'index' } to /forms" do
      route_for(:controller => "forms", :action => "index").should == "/forms"
    end
  
    it "should map { :controller => 'forms', :action => 'new' } to /forms/new" do
      route_for(:controller => "forms", :action => "new").should == "/forms/new"
    end
  
    it "should map { :controller => 'forms', :action => 'show', :id => 1 } to /forms/1" do
      route_for(:controller => "forms", :action => "show", :id => 1).should == "/forms/1"
    end
  
    it "should map { :controller => 'forms', :action => 'edit', :id => 1 } to /forms/1/edit" do
      route_for(:controller => "forms", :action => "edit", :id => 1).should == "/forms/1/edit"
    end
  
    it "should map { :controller => 'forms', :action => 'update', :id => 1} to /forms/1" do
      route_for(:controller => "forms", :action => "update", :id => 1).should == "/forms/1"
    end
  
    it "should map { :controller => 'forms', :action => 'destroy', :id => 1} to /forms/1" do
      route_for(:controller => "forms", :action => "destroy", :id => 1).should == "/forms/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'forms', action => 'index' } from GET /forms" do
      params_from(:get, "/forms").should == {:controller => "forms", :action => "index"}
    end
  
    it "should generate params { :controller => 'forms', action => 'new' } from GET /forms/new" do
      params_from(:get, "/forms/new").should == {:controller => "forms", :action => "new"}
    end
  
    it "should generate params { :controller => 'forms', action => 'create' } from POST /forms" do
      params_from(:post, "/forms").should == {:controller => "forms", :action => "create"}
    end
  
    it "should generate params { :controller => 'forms', action => 'show', id => '1' } from GET /forms/1" do
      params_from(:get, "/forms/1").should == {:controller => "forms", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'forms', action => 'edit', id => '1' } from GET /forms/1;edit" do
      params_from(:get, "/forms/1/edit").should == {:controller => "forms", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'forms', action => 'update', id => '1' } from PUT /forms/1" do
      params_from(:put, "/forms/1").should == {:controller => "forms", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'forms', action => 'destroy', id => '1' } from DELETE /forms/1" do
      params_from(:delete, "/forms/1").should == {:controller => "forms", :action => "destroy", :id => "1"}
    end
  end
end