require File.dirname(__FILE__) + '/../spec_helper'

describe CliniciansController do
  describe "route generation" do

    it "should map { :controller => 'clinicians', :action => 'index' } to /clinicians" do
      route_for(:controller => "clinicians", :action => "index").should == "/clinicians"
    end
  
    it "should map { :controller => 'clinicians', :action => 'new' } to /clinicians/new" do
      route_for(:controller => "clinicians", :action => "new").should == "/clinicians/new"
    end
  
    it "should map { :controller => 'clinicians', :action => 'show', :id => 1, :cmr_id => 2 } to /cmrs/2/clinicians/1" do
      route_for(:controller => "clinicians", :action => "show", :id => 1,  :cmr_id => 2).should == "/cmrs/2/clinicians/1"
    end
  
    it "should map { :controller => 'clinicians', :action => 'edit', :id => 1, :cmr_id => 2  } to /cmrs/2/clinicians/1/edit" do
      route_for(:controller => "clinicians", :action => "edit", :id => 1, :cmr_id => 2).should == "/cmrs/2/clinicians/1/edit"
    end
  
    it "should map { :controller => 'clinicians', :action => 'update', :id => 1, :cmr_id => 2 } to /cmrs/2/clinicians/1" do
      route_for(:controller => "clinicians", :action => "update", :id => 1, :cmr_id => 2).should == "/cmrs/2/clinicians/1"
    end
  
    it "should map { :controller => 'clinicians', :action => 'destroy', :id => 1, :cmr_id => 2 } to /cmrs/2/clinicians/1" do
      route_for(:controller => "clinicians", :action => "destroy", :id => 1, :cmr_id => 2).should == "/cmrs/2/clinicians/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'clinicians', action => 'index' } from GET /clinicians" do
      params_from(:get, "/clinicians").should == {:controller => "clinicians", :action => "index"}
    end
  
    it "should generate params { :controller => 'clinicians', action => 'new' } from GET /clinicians/new" do
      params_from(:get, "/clinicians/new").should == {:controller => "clinicians", :action => "new"}
    end
  
    it "should generate params { :controller => 'clinicians', action => 'create', :cmr_id => '2'} from POST /cmrs/2/clinicians" do
      params_from(:post, "/cmrs/2/clinicians").should == {:controller => "clinicians", :action => "create", :cmr_id => "2"}
    end
  
    it "should generate params { :controller => 'clinicians', action => 'show', id => '1', :cmr_id => '2' } from GET /cmrs/2/clinicians/1" do
      params_from(:get, "/cmrs/2/clinicians/1").should == {:controller => "clinicians", :action => "show", :id => "1", :cmr_id => "2"}
    end
  
    it "should generate params { :controller => 'clinicians', action => 'edit', id => '1', :cmr_id =>  '2' } from GET /cmrs/2/clinicians/1;edit" do
      params_from(:get, "/cmrs/2/clinicians/1/edit").should == {:controller => "clinicians", :action => "edit", :id => "1", :cmr_id => "2"}
    end
  
    it "should generate params { :controller => 'clinicians', action => 'update', id => '1', :cmr_id =>  '2' } from PUT /cmrs/2/clinicians/1" do
      params_from(:put, "/cmrs/2/clinicians/1").should == {:controller => "clinicians", :action => "update", :id => "1", :cmr_id => "2"}
    end
  
    it "should generate params { :controller => 'clinicians', action => 'destroy', id => '1', :cmr_id =>  '2' } from DELETE /cmrs/2/clinicians/1" do
      params_from(:delete, "/cmrs/2/clinicians/1").should == {:controller => "clinicians", :action => "destroy", :id => "1", :cmr_id => "2"}
    end
  end
end