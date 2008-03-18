require File.dirname(__FILE__) + '/../spec_helper'

describe AdminController do
  describe "route generation" do
    it "should map { :controller => 'admin', :action => 'index' } to /admin" do
      route_for(:controller => "admin", :action => "index").should == "/admin"
    end
  end

  describe "route recognition" do
    it "should generate params { :controller => 'admin', action => 'index' } from GET /admin" do
      params_from(:get, "/admin").should == {:controller => "admin", :action => "index"}
    end
  end
end
