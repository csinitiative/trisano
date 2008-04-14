require File.dirname(__FILE__) + '/../spec_helper'

describe ProgramsController do
  describe "route generation" do

    it "should map { :controller => 'programs', :action => 'index' } to /programs" do
      route_for(:controller => "programs", :action => "index").should == "/programs"
    end
  
    it "should map { :controller => 'programs', :action => 'new' } to /programs/new" do
      route_for(:controller => "programs", :action => "new").should == "/programs/new"
    end
  
    it "should map { :controller => 'programs', :action => 'show', :id => 1 } to /programs/1" do
      route_for(:controller => "programs", :action => "show", :id => 1).should == "/programs/1"
    end
  
    it "should map { :controller => 'programs', :action => 'edit', :id => 1 } to /programs/1/edit" do
      route_for(:controller => "programs", :action => "edit", :id => 1).should == "/programs/1/edit"
    end
  
    it "should map { :controller => 'programs', :action => 'update', :id => 1} to /programs/1" do
      route_for(:controller => "programs", :action => "update", :id => 1).should == "/programs/1"
    end
  
    it "should map { :controller => 'programs', :action => 'destroy', :id => 1} to /programs/1" do
      route_for(:controller => "programs", :action => "destroy", :id => 1).should == "/programs/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'programs', action => 'index' } from GET /programs" do
      params_from(:get, "/programs").should == {:controller => "programs", :action => "index"}
    end
  
    it "should generate params { :controller => 'programs', action => 'new' } from GET /programs/new" do
      params_from(:get, "/programs/new").should == {:controller => "programs", :action => "new"}
    end
  
    it "should generate params { :controller => 'programs', action => 'create' } from POST /programs" do
      params_from(:post, "/programs").should == {:controller => "programs", :action => "create"}
    end
  
    it "should generate params { :controller => 'programs', action => 'show', id => '1' } from GET /programs/1" do
      params_from(:get, "/programs/1").should == {:controller => "programs", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'programs', action => 'edit', id => '1' } from GET /programs/1;edit" do
      params_from(:get, "/programs/1/edit").should == {:controller => "programs", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'programs', action => 'update', id => '1' } from PUT /programs/1" do
      params_from(:put, "/programs/1").should == {:controller => "programs", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'programs', action => 'destroy', id => '1' } from DELETE /programs/1" do
      params_from(:delete, "/programs/1").should == {:controller => "programs", :action => "destroy", :id => "1"}
    end
  end
end