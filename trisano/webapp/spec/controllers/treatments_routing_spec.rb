# Copyright (C) 2007, 2008, The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the 
# terms of the GNU Affero General Public License as published by the 
# Free Software Foundation, either version 3 of the License, 
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

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
