require File.dirname(__FILE__) + '/../spec_helper'

describe SectionsController do
  describe "route generation" do

    it "should map { :controller => 'sections', :action => 'index' } to /sections" do
      route_for(:controller => "sections", :action => "index").should == "/sections"
    end
  
    it "should map { :controller => 'sections', :action => 'new' } to /sections/new" do
      route_for(:controller => "sections", :action => "new").should == "/sections/new"
    end
  
    it "should map { :controller => 'sections', :action => 'show', :id => 1 } to /sections/1" do
      route_for(:controller => "sections", :action => "show", :id => 1).should == "/sections/1"
    end
  
    it "should map { :controller => 'sections', :action => 'edit', :id => 1 } to /sections/1/edit" do
      route_for(:controller => "sections", :action => "edit", :id => 1).should == "/sections/1/edit"
    end
  
    it "should map { :controller => 'sections', :action => 'update', :id => 1} to /sections/1" do
      route_for(:controller => "sections", :action => "update", :id => 1).should == "/sections/1"
    end
  
    it "should map { :controller => 'sections', :action => 'destroy', :id => 1} to /sections/1" do
      route_for(:controller => "sections", :action => "destroy", :id => 1).should == "/sections/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'sections', action => 'index' } from GET /sections" do
      params_from(:get, "/sections").should == {:controller => "sections", :action => "index"}
    end
  
    it "should generate params { :controller => 'sections', action => 'new' } from GET /sections/new" do
      params_from(:get, "/sections/new").should == {:controller => "sections", :action => "new"}
    end
  
    it "should generate params { :controller => 'sections', action => 'create' } from POST /sections" do
      params_from(:post, "/sections").should == {:controller => "sections", :action => "create"}
    end
  
    it "should generate params { :controller => 'sections', action => 'show', id => '1' } from GET /sections/1" do
      params_from(:get, "/sections/1").should == {:controller => "sections", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'sections', action => 'edit', id => '1' } from GET /sections/1;edit" do
      params_from(:get, "/sections/1/edit").should == {:controller => "sections", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'sections', action => 'update', id => '1' } from PUT /sections/1" do
      params_from(:put, "/sections/1").should == {:controller => "sections", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'sections', action => 'destroy', id => '1' } from DELETE /sections/1" do
      params_from(:delete, "/sections/1").should == {:controller => "sections", :action => "destroy", :id => "1"}
    end
  end
end