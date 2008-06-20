require File.dirname(__FILE__) + '/../spec_helper'

describe CliniciansController do
  describe "route generation" do

    it "should map { :controller => 'treatments', :action => 'index' } to /treatments" do
      route_for(:controller => "treatments", :action => "index").should == "/treatments"
    end
  
    it "should map { :controller => 'treatments', :action => 'new' } to /treatments/new" do
      route_for(:controller => "treatments", :action => "new").should == "/treatments/new"
    end
  
    it "should map { :controller => 'treatments', :action => 'show', :id => 1, :cmr_id => 2 } to /cmrs/2/treatments/1" do
      route_for(:controller => "treatments", :action => "show", :id => 1,  :cmr_id => 2).should == "/cmrs/2/treatments/1"
    end
  
    it "should map { :controller => 'treatments', :action => 'edit', :id => 1, :cmr_id => 2  } to /cmrs/2/treatments/1/edit" do
      route_for(:controller => "treatments", :action => "edit", :id => 1, :cmr_id => 2).should == "/cmrs/2/treatments/1/edit"
    end
  
    it "should map { :controller => 'treatments', :action => 'update', :id => 1, :cmr_id => 2 } to /cmrs/2/treatments/1" do
      route_for(:controller => "treatments", :action => "update", :id => 1, :cmr_id => 2).should == "/cmrs/2/treatments/1"
    end
  
    it "should map { :controller => 'treatments', :action => 'destroy', :id => 1, :cmr_id => 2 } to /cmrs/2/treatments/1" do
      route_for(:controller => "treatments", :action => "destroy", :id => 1, :cmr_id => 2).should == "/cmrs/2/treatments/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'treatments', action => 'index' } from GET /treatments" do
      params_from(:get, "/treatments").should == {:controller => "treatments", :action => "index"}
    end
  
    it "should generate params { :controller => 'treatments', action => 'new' } from GET /treatments/new" do
      params_from(:get, "/treatments/new").should == {:controller => "treatments", :action => "new"}
    end
  
    it "should generate params { :controller => 'treatments', action => 'create', :cmr_id => '2'} from POST /cmrs/2/treatments" do
      params_from(:post, "/cmrs/2/treatments").should == {:controller => "treatments", :action => "create", :cmr_id => "2"}
    end
  
    it "should generate params { :controller => 'treatments', action => 'show', id => '1', :cmr_id => '2' } from GET /cmrs/2/treatments/1" do
      params_from(:get, "/cmrs/2/treatments/1").should == {:controller => "treatments", :action => "show", :id => "1", :cmr_id => "2"}
    end
  
    it "should generate params { :controller => 'treatments', action => 'edit', id => '1', :cmr_id =>  '2' } from GET /cmrs/2/treatments/1;edit" do
      params_from(:get, "/cmrs/2/treatments/1/edit").should == {:controller => "treatments", :action => "edit", :id => "1", :cmr_id => "2"}
    end
  
    it "should generate params { :controller => 'treatments', action => 'update', id => '1', :cmr_id =>  '2' } from PUT /cmrs/2/treatments/1" do
      params_from(:put, "/cmrs/2/treatments/1").should == {:controller => "treatments", :action => "update", :id => "1", :cmr_id => "2"}
    end
  
    it "should generate params { :controller => 'treatments', action => 'destroy', id => '1', :cmr_id =>  '2' } from DELETE /cmrs/2/treatments/1" do
      params_from(:delete, "/cmrs/2/treatments/1").should == {:controller => "treatments", :action => "destroy", :id => "1", :cmr_id => "2"}
    end
  end
end
