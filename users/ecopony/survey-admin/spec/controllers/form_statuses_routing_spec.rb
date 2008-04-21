require File.dirname(__FILE__) + '/../spec_helper'

describe FormStatusesController do
  describe "route generation" do

    it "should map { :controller => 'form_statuses', :action => 'index' } to /form_statuses" do
      route_for(:controller => "form_statuses", :action => "index").should == "/form_statuses"
    end
  
    it "should map { :controller => 'form_statuses', :action => 'new' } to /form_statuses/new" do
      route_for(:controller => "form_statuses", :action => "new").should == "/form_statuses/new"
    end
  
    it "should map { :controller => 'form_statuses', :action => 'show', :id => 1 } to /form_statuses/1" do
      route_for(:controller => "form_statuses", :action => "show", :id => 1).should == "/form_statuses/1"
    end
  
    it "should map { :controller => 'form_statuses', :action => 'edit', :id => 1 } to /form_statuses/1/edit" do
      route_for(:controller => "form_statuses", :action => "edit", :id => 1).should == "/form_statuses/1/edit"
    end
  
    it "should map { :controller => 'form_statuses', :action => 'update', :id => 1} to /form_statuses/1" do
      route_for(:controller => "form_statuses", :action => "update", :id => 1).should == "/form_statuses/1"
    end
  
    it "should map { :controller => 'form_statuses', :action => 'destroy', :id => 1} to /form_statuses/1" do
      route_for(:controller => "form_statuses", :action => "destroy", :id => 1).should == "/form_statuses/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'form_statuses', action => 'index' } from GET /form_statuses" do
      params_from(:get, "/form_statuses").should == {:controller => "form_statuses", :action => "index"}
    end
  
    it "should generate params { :controller => 'form_statuses', action => 'new' } from GET /form_statuses/new" do
      params_from(:get, "/form_statuses/new").should == {:controller => "form_statuses", :action => "new"}
    end
  
    it "should generate params { :controller => 'form_statuses', action => 'create' } from POST /form_statuses" do
      params_from(:post, "/form_statuses").should == {:controller => "form_statuses", :action => "create"}
    end
  
    it "should generate params { :controller => 'form_statuses', action => 'show', id => '1' } from GET /form_statuses/1" do
      params_from(:get, "/form_statuses/1").should == {:controller => "form_statuses", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'form_statuses', action => 'edit', id => '1' } from GET /form_statuses/1;edit" do
      params_from(:get, "/form_statuses/1/edit").should == {:controller => "form_statuses", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'form_statuses', action => 'update', id => '1' } from PUT /form_statuses/1" do
      params_from(:put, "/form_statuses/1").should == {:controller => "form_statuses", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'form_statuses', action => 'destroy', id => '1' } from DELETE /form_statuses/1" do
      params_from(:delete, "/form_statuses/1").should == {:controller => "form_statuses", :action => "destroy", :id => "1"}
    end
  end
end