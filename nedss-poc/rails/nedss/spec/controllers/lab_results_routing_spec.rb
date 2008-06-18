require File.dirname(__FILE__) + '/../spec_helper'

describe LabResultsController do
  describe "route generation" do

    it "should map { :controller => 'lab_results', :action => 'index' } to /lab_results" do
      route_for(:controller => "lab_results", :action => "index").should == "/lab_results"
    end
  
    it "should map { :controller => 'lab_results', :action => 'new' } to /lab_results/new" do
      route_for(:controller => "lab_results", :action => "new").should == "/lab_results/new"
    end
  
    it "should map { :controller => 'lab_results', :action => 'show', :id => 1, :cmr_id => 2 } to /cmrs/2/lab_results/1" do
      route_for(:controller => "lab_results", :action => "show", :id => 1,  :cmr_id => 2).should == "/cmrs/2/lab_results/1"
    end
  
    it "should map { :controller => 'lab_results', :action => 'edit', :id => 1, :cmr_id => 2  } to /cmrs/2/lab_results/1/edit" do
      route_for(:controller => "lab_results", :action => "edit", :id => 1, :cmr_id => 2).should == "/cmrs/2/lab_results/1/edit"
    end
  
    it "should map { :controller => 'lab_results', :action => 'update', :id => 1, :cmr_id => 2 } to /cmrs/2/lab_results/1" do
      route_for(:controller => "lab_results", :action => "update", :id => 1, :cmr_id => 2).should == "/cmrs/2/lab_results/1"
    end
  
    it "should map { :controller => 'lab_results', :action => 'destroy', :id => 1, :cmr_id => 2 } to /cmrs/2/lab_results/1" do
      route_for(:controller => "lab_results", :action => "destroy", :id => 1, :cmr_id => 2).should == "/cmrs/2/lab_results/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'lab_results', action => 'index' } from GET /lab_results" do
      params_from(:get, "/lab_results").should == {:controller => "lab_results", :action => "index"}
    end
  
    it "should generate params { :controller => 'lab_results', action => 'new' } from GET /lab_results/new" do
      params_from(:get, "/lab_results/new").should == {:controller => "lab_results", :action => "new"}
    end
  
    it "should generate params { :controller => 'lab_results', action => 'create', :cmr_id => '2'} from POST /cmrs/2/lab_results" do
      params_from(:post, "/cmrs/2/lab_results").should == {:controller => "lab_results", :action => "create", :cmr_id => "2"}
    end
  
    it "should generate params { :controller => 'lab_results', action => 'show', id => '1', :cmr_id => '2' } from GET /cmrs/2/lab_results/1" do
      params_from(:get, "/cmrs/2/lab_results/1").should == {:controller => "lab_results", :action => "show", :id => "1", :cmr_id => "2"}
    end
  
    it "should generate params { :controller => 'lab_results', action => 'edit', id => '1', :cmr_id =>  '2' } from GET /cmrs/2/lab_results/1;edit" do
      params_from(:get, "/cmrs/2/lab_results/1/edit").should == {:controller => "lab_results", :action => "edit", :id => "1", :cmr_id => "2"}
    end
  
    it "should generate params { :controller => 'lab_results', action => 'update', id => '1', :cmr_id =>  '2' } from PUT /cmrs/2/lab_results/1" do
      params_from(:put, "/cmrs/2/lab_results/1").should == {:controller => "lab_results", :action => "update", :id => "1", :cmr_id => "2"}
    end
  
    it "should generate params { :controller => 'lab_results', action => 'destroy', id => '1', :cmr_id =>  '2' } from DELETE /cmrs/2/lab_results/1" do
      params_from(:delete, "/cmrs/2/lab_results/1").should == {:controller => "lab_results", :action => "destroy", :id => "1", :cmr_id => "2"}
    end
  end
end
