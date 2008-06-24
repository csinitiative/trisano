require File.dirname(__FILE__) + '/../spec_helper'

describe HealthFacilitiesController do
  describe "route generation" do

    it "should map { :controller => 'health_facilities', :action => 'index' } to /health_facilities" do
      route_for(:controller => "health_facilities", :action => "index").should == "/health_facilities"
    end
  
    it "should map { :controller => 'health_facilities', :action => 'new' } to /health_facilities/new" do
      route_for(:controller => "health_facilities", :action => "new").should == "/health_facilities/new"
    end
  
    it "should map { :controller => 'health_facilities', :action => 'show', :id => 1, :cmr_id => 2 } to /cmrs/2/health_facilities/1" do
      route_for(:controller => "health_facilities", :action => "show", :id => 1,  :cmr_id => 2).should == "/cmrs/2/health_facilities/1"
    end
  
    it "should map { :controller => 'health_facilities', :action => 'edit', :id => 1, :cmr_id => 2  } to /cmrs/2/health_facilities/1/edit" do
      route_for(:controller => "health_facilities", :action => "edit", :id => 1, :cmr_id => 2).should == "/cmrs/2/health_facilities/1/edit"
    end
  
    it "should map { :controller => 'health_facilities', :action => 'update', :id => 1, :cmr_id => 2 } to /cmrs/2/health_facilities/1" do
      route_for(:controller => "health_facilities", :action => "update", :id => 1, :cmr_id => 2).should == "/cmrs/2/health_facilities/1"
    end
  
    it "should map { :controller => 'health_facilities', :action => 'destroy', :id => 1, :cmr_id => 2 } to /cmrs/2/health_facilities/1" do
      route_for(:controller => "health_facilities", :action => "destroy", :id => 1, :cmr_id => 2).should == "/cmrs/2/health_facilities/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'health_facilities', action => 'index' } from GET /health_facilities" do
      params_from(:get, "/health_facilities").should == {:controller => "health_facilities", :action => "index"}
    end
  
    it "should generate params { :controller => 'health_facilities', action => 'new' } from GET /health_facilities/new" do
      params_from(:get, "/health_facilities/new").should == {:controller => "health_facilities", :action => "new"}
    end
  
    it "should generate params { :controller => 'health_facilities', action => 'create', :cmr_id => '2'} from POST /cmrs/2/health_facilities" do
      params_from(:post, "/cmrs/2/health_facilities").should == {:controller => "health_facilities", :action => "create", :cmr_id => "2"}
    end
  
    it "should generate params { :controller => 'health_facilities', action => 'show', id => '1', :cmr_id => '2' } from GET /cmrs/2/health_facilities/1" do
      params_from(:get, "/cmrs/2/health_facilities/1").should == {:controller => "health_facilities", :action => "show", :id => "1", :cmr_id => "2"}
    end
  
    it "should generate params { :controller => 'health_facilities', action => 'edit', id => '1', :cmr_id =>  '2' } from GET /cmrs/2/health_facilities/1;edit" do
      params_from(:get, "/cmrs/2/health_facilities/1/edit").should == {:controller => "health_facilities", :action => "edit", :id => "1", :cmr_id => "2"}
    end
  
    it "should generate params { :controller => 'health_facilities', action => 'update', id => '1', :cmr_id =>  '2' } from PUT /cmrs/2/health_facilities/1" do
      params_from(:put, "/cmrs/2/health_facilities/1").should == {:controller => "health_facilities", :action => "update", :id => "1", :cmr_id => "2"}
    end
  
    it "should generate params { :controller => 'health_facilities', action => 'destroy', id => '1', :cmr_id =>  '2' } from DELETE /cmrs/2/health_facilities/1" do
      params_from(:delete, "/cmrs/2/health_facilities/1").should == {:controller => "health_facilities", :action => "destroy", :id => "1", :cmr_id => "2"}
    end
  end
end