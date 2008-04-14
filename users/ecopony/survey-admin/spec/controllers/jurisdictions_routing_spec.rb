require File.dirname(__FILE__) + '/../spec_helper'

describe JurisdictionsController do
  describe "route generation" do

    it "should map { :controller => 'jurisdictions', :action => 'index' } to /jurisdictions" do
      route_for(:controller => "jurisdictions", :action => "index").should == "/jurisdictions"
    end
  
    it "should map { :controller => 'jurisdictions', :action => 'new' } to /jurisdictions/new" do
      route_for(:controller => "jurisdictions", :action => "new").should == "/jurisdictions/new"
    end
  
    it "should map { :controller => 'jurisdictions', :action => 'show', :id => 1 } to /jurisdictions/1" do
      route_for(:controller => "jurisdictions", :action => "show", :id => 1).should == "/jurisdictions/1"
    end
  
    it "should map { :controller => 'jurisdictions', :action => 'edit', :id => 1 } to /jurisdictions/1/edit" do
      route_for(:controller => "jurisdictions", :action => "edit", :id => 1).should == "/jurisdictions/1/edit"
    end
  
    it "should map { :controller => 'jurisdictions', :action => 'update', :id => 1} to /jurisdictions/1" do
      route_for(:controller => "jurisdictions", :action => "update", :id => 1).should == "/jurisdictions/1"
    end
  
    it "should map { :controller => 'jurisdictions', :action => 'destroy', :id => 1} to /jurisdictions/1" do
      route_for(:controller => "jurisdictions", :action => "destroy", :id => 1).should == "/jurisdictions/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'jurisdictions', action => 'index' } from GET /jurisdictions" do
      params_from(:get, "/jurisdictions").should == {:controller => "jurisdictions", :action => "index"}
    end
  
    it "should generate params { :controller => 'jurisdictions', action => 'new' } from GET /jurisdictions/new" do
      params_from(:get, "/jurisdictions/new").should == {:controller => "jurisdictions", :action => "new"}
    end
  
    it "should generate params { :controller => 'jurisdictions', action => 'create' } from POST /jurisdictions" do
      params_from(:post, "/jurisdictions").should == {:controller => "jurisdictions", :action => "create"}
    end
  
    it "should generate params { :controller => 'jurisdictions', action => 'show', id => '1' } from GET /jurisdictions/1" do
      params_from(:get, "/jurisdictions/1").should == {:controller => "jurisdictions", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'jurisdictions', action => 'edit', id => '1' } from GET /jurisdictions/1;edit" do
      params_from(:get, "/jurisdictions/1/edit").should == {:controller => "jurisdictions", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'jurisdictions', action => 'update', id => '1' } from PUT /jurisdictions/1" do
      params_from(:put, "/jurisdictions/1").should == {:controller => "jurisdictions", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'jurisdictions', action => 'destroy', id => '1' } from DELETE /jurisdictions/1" do
      params_from(:delete, "/jurisdictions/1").should == {:controller => "jurisdictions", :action => "destroy", :id => "1"}
    end
  end
end