require File.dirname(__FILE__) + '/../spec_helper'

describe CliniciansController do
  describe "route generation" do

    it "should map { :controller => 'contacts', :action => 'index' } to /contacts" do
      route_for(:controller => "contacts", :action => "index").should == "/contacts"
    end
  
    it "should map { :controller => 'contacts', :action => 'new' } to /contacts/new" do
      route_for(:controller => "contacts", :action => "new").should == "/contacts/new"
    end
  
    it "should map { :controller => 'contacts', :action => 'show', :id => 1, :cmr_id => 2 } to /cmrs/2/contacts/1" do
      route_for(:controller => "contacts", :action => "show", :id => 1,  :cmr_id => 2).should == "/cmrs/2/contacts/1"
    end
  
    it "should map { :controller => 'contacts', :action => 'edit', :id => 1, :cmr_id => 2  } to /cmrs/2/contacts/1/edit" do
      route_for(:controller => "contacts", :action => "edit", :id => 1, :cmr_id => 2).should == "/cmrs/2/contacts/1/edit"
    end
  
    it "should map { :controller => 'contacts', :action => 'update', :id => 1, :cmr_id => 2 } to /cmrs/2/contacts/1" do
      route_for(:controller => "contacts", :action => "update", :id => 1, :cmr_id => 2).should == "/cmrs/2/contacts/1"
    end
  
    it "should map { :controller => 'contacts', :action => 'destroy', :id => 1, :cmr_id => 2 } to /cmrs/2/contacts/1" do
      route_for(:controller => "contacts", :action => "destroy", :id => 1, :cmr_id => 2).should == "/cmrs/2/contacts/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'contacts', action => 'index' } from GET /contacts" do
      params_from(:get, "/contacts").should == {:controller => "contacts", :action => "index"}
    end
  
    it "should generate params { :controller => 'contacts', action => 'new' } from GET /contacts/new" do
      params_from(:get, "/contacts/new").should == {:controller => "contacts", :action => "new"}
    end
  
    it "should generate params { :controller => 'contacts', action => 'create', :cmr_id => '2'} from POST /cmrs/2/contacts" do
      params_from(:post, "/cmrs/2/contacts").should == {:controller => "contacts", :action => "create", :cmr_id => "2"}
    end
  
    it "should generate params { :controller => 'contacts', action => 'show', id => '1', :cmr_id => '2' } from GET /cmrs/2/contacts/1" do
      params_from(:get, "/cmrs/2/contacts/1").should == {:controller => "contacts", :action => "show", :id => "1", :cmr_id => "2"}
    end
  
    it "should generate params { :controller => 'contacts', action => 'edit', id => '1', :cmr_id =>  '2' } from GET /cmrs/2/contacts/1;edit" do
      params_from(:get, "/cmrs/2/contacts/1/edit").should == {:controller => "contacts", :action => "edit", :id => "1", :cmr_id => "2"}
    end
  
    it "should generate params { :controller => 'contacts', action => 'update', id => '1', :cmr_id =>  '2' } from PUT /cmrs/2/contacts/1" do
      params_from(:put, "/cmrs/2/contacts/1").should == {:controller => "contacts", :action => "update", :id => "1", :cmr_id => "2"}
    end
  
    it "should generate params { :controller => 'contacts', action => 'destroy', id => '1', :cmr_id =>  '2' } from DELETE /cmrs/2/contacts/1" do
      params_from(:delete, "/cmrs/2/contacts/1").should == {:controller => "contacts", :action => "destroy", :id => "1", :cmr_id => "2"}
    end
  end
end
