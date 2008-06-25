require File.dirname(__FILE__) + '/../spec_helper'

describe ExternalCodesController do
  describe "route generation" do

    it "should map { :controller => 'external_codes', :action => 'index' } to /external_codes" do
      route_for(:controller => "external_codes", :action => "index").should == "/external_codes"
    end
  
    it "should map { :controller => 'external_codes', :action => 'new' } to /external_codes/new" do
      route_for(:controller => "external_codes", :action => "new").should == "/external_codes/new"
    end
  
    it "should map { :controller => 'external_codes', :action => 'show', :id => 1 } to /external_codes/1" do
      route_for(:controller => "external_codes", :action => "show", :id => 1).should == "/external_codes/1"
    end
  
    it "should map { :controller => 'external_codes', :action => 'edit', :id => 1 } to /external_codes/1/edit" do
      route_for(:controller => "external_codes", :action => "edit", :id => 1).should == "/external_codes/1/edit"
    end
  
    it "should map { :controller => 'external_codes', :action => 'update', :id => 1} to /external_codes/1" do
      route_for(:controller => "external_codes", :action => "update", :id => 1).should == "/external_codes/1"
    end
  
    it "should map { :controller => 'external_codes', :action => 'destroy', :id => 1} to /external_codes/1" do
      route_for(:controller => "external_codes", :action => "destroy", :id => 1).should == "/external_codes/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'external_codes', action => 'index' } from GET /external_codes" do
      params_from(:get, "/external_codes").should == {:controller => "external_codes", :action => "index"}
    end
  
    it "should generate params { :controller => 'external_codes', action => 'new' } from GET /external_codes/new" do
      params_from(:get, "/external_codes/new").should == {:controller => "external_codes", :action => "new"}
    end
  
    it "should generate params { :controller => 'external_codes', action => 'create' } from POST /external_codes" do
      params_from(:post, "/external_codes").should == {:controller => "external_codes", :action => "create"}
    end
  
    it "should generate params { :controller => 'external_codes', action => 'show', id => '1' } from GET /external_codes/1" do
      params_from(:get, "/external_codes/1").should == {:controller => "external_codes", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'external_codes', action => 'edit', id => '1' } from GET /external_codes/1;edit" do
      params_from(:get, "/external_codes/1/edit").should == {:controller => "external_codes", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'external_codes', action => 'update', id => '1' } from PUT /external_codes/1" do
      params_from(:put, "/external_codes/1").should == {:controller => "external_codes", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'external_codes', action => 'destroy', id => '1' } from DELETE /external_codes/1" do
      params_from(:delete, "/external_codes/1").should == {:controller => "external_codes", :action => "destroy", :id => "1"}
    end
  end
end