require File.dirname(__FILE__) + '/../spec_helper'

describe DiseasesController do
  describe "route generation" do

    it "should map { :controller => 'diseases', :action => 'index' } to /diseases" do
      route_for(:controller => "diseases", :action => "index").should == "/diseases"
    end
  
    it "should map { :controller => 'diseases', :action => 'new' } to /diseases/new" do
      route_for(:controller => "diseases", :action => "new").should == "/diseases/new"
    end
  
    it "should map { :controller => 'diseases', :action => 'show', :id => 1 } to /diseases/1" do
      route_for(:controller => "diseases", :action => "show", :id => 1).should == "/diseases/1"
    end
  
    it "should map { :controller => 'diseases', :action => 'edit', :id => 1 } to /diseases/1/edit" do
      route_for(:controller => "diseases", :action => "edit", :id => 1).should == "/diseases/1/edit"
    end
  
    it "should map { :controller => 'diseases', :action => 'update', :id => 1} to /diseases/1" do
      route_for(:controller => "diseases", :action => "update", :id => 1).should == "/diseases/1"
    end
  
    it "should map { :controller => 'diseases', :action => 'destroy', :id => 1} to /diseases/1" do
      route_for(:controller => "diseases", :action => "destroy", :id => 1).should == "/diseases/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'diseases', action => 'index' } from GET /diseases" do
      params_from(:get, "/diseases").should == {:controller => "diseases", :action => "index"}
    end
  
    it "should generate params { :controller => 'diseases', action => 'new' } from GET /diseases/new" do
      params_from(:get, "/diseases/new").should == {:controller => "diseases", :action => "new"}
    end
  
    it "should generate params { :controller => 'diseases', action => 'create' } from POST /diseases" do
      params_from(:post, "/diseases").should == {:controller => "diseases", :action => "create"}
    end
  
    it "should generate params { :controller => 'diseases', action => 'show', id => '1' } from GET /diseases/1" do
      params_from(:get, "/diseases/1").should == {:controller => "diseases", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'diseases', action => 'edit', id => '1' } from GET /diseases/1;edit" do
      params_from(:get, "/diseases/1/edit").should == {:controller => "diseases", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'diseases', action => 'update', id => '1' } from PUT /diseases/1" do
      params_from(:put, "/diseases/1").should == {:controller => "diseases", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'diseases', action => 'destroy', id => '1' } from DELETE /diseases/1" do
      params_from(:delete, "/diseases/1").should == {:controller => "diseases", :action => "destroy", :id => "1"}
    end
  end
end