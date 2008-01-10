require File.dirname(__FILE__) + '/../spec_helper'

describe PatientsController do
  describe "route generation" do

    it "should map { :controller => 'patients', :action => 'index' } to /patients" do
      route_for(:controller => "patients", :action => "index").should == "/patients"
    end
  
    it "should map { :controller => 'patients', :action => 'new' } to /patients/new" do
      route_for(:controller => "patients", :action => "new").should == "/patients/new"
    end
  
    it "should map { :controller => 'patients', :action => 'show', :id => 1 } to /patients/1" do
      route_for(:controller => "patients", :action => "show", :id => 1).should == "/patients/1"
    end
  
    it "should map { :controller => 'patients', :action => 'edit', :id => 1 } to /patients/1/edit" do
      route_for(:controller => "patients", :action => "edit", :id => 1).should == "/patients/1/edit"
    end
  
    it "should map { :controller => 'patients', :action => 'update', :id => 1} to /patients/1" do
      route_for(:controller => "patients", :action => "update", :id => 1).should == "/patients/1"
    end
  
    it "should map { :controller => 'patients', :action => 'destroy', :id => 1} to /patients/1" do
      route_for(:controller => "patients", :action => "destroy", :id => 1).should == "/patients/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'patients', action => 'index' } from GET /patients" do
      params_from(:get, "/patients").should == {:controller => "patients", :action => "index"}
    end
  
    it "should generate params { :controller => 'patients', action => 'new' } from GET /patients/new" do
      params_from(:get, "/patients/new").should == {:controller => "patients", :action => "new"}
    end
  
    it "should generate params { :controller => 'patients', action => 'create' } from POST /patients" do
      params_from(:post, "/patients").should == {:controller => "patients", :action => "create"}
    end
  
    it "should generate params { :controller => 'patients', action => 'show', id => '1' } from GET /patients/1" do
      params_from(:get, "/patients/1").should == {:controller => "patients", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'patients', action => 'edit', id => '1' } from GET /patients/1;edit" do
      params_from(:get, "/patients/1/edit").should == {:controller => "patients", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'patients', action => 'update', id => '1' } from PUT /patients/1" do
      params_from(:put, "/patients/1").should == {:controller => "patients", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'patients', action => 'destroy', id => '1' } from DELETE /patients/1" do
      params_from(:delete, "/patients/1").should == {:controller => "patients", :action => "destroy", :id => "1"}
    end
  end
end