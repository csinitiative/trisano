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

describe ExternalCodesController do
  describe "route generation" do

    it "should map { :controller => 'external_codes', :action => 'index' } to /external_codes" do
      route_for(:controller => "external_codes", :action => "index").should == "/external_codes"
    end
  
    it "should map { :controller => 'external_codes', :action => 'new' } to /external_codes/new" do
      route_for(:controller => "external_codes", :action => "new").should == "/external_codes/new"
    end
  
    it "should map { :controller => 'external_codes', :action => 'show', :id => 1 } to /external_codes/1" do
      route_for(:controller => "external_codes", :action => "show", :id => 1).should == "/external_codes/1"
    end
  
    it "should map { :controller => 'external_codes', :action => 'edit', :id => 1 } to /external_codes/1/edit" do
      route_for(:controller => "external_codes", :action => "edit", :id => 1).should == "/external_codes/1/edit"
    end
  
    it "should map { :controller => 'external_codes', :action => 'update', :id => 1} to /external_codes/1" do
      route_for(:controller => "external_codes", :action => "update", :id => 1).should == "/external_codes/1"
    end
  
    it "should map { :controller => 'external_codes', :action => 'destroy', :id => 1} to /external_codes/1" do
      route_for(:controller => "external_codes", :action => "destroy", :id => 1).should == "/external_codes/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'external_codes', action => 'index' } from GET /external_codes" do
      params_from(:get, "/external_codes").should == {:controller => "external_codes", :action => "index"}
    end
  
    it "should generate params { :controller => 'external_codes', action => 'new' } from GET /external_codes/new" do
      params_from(:get, "/external_codes/new").should == {:controller => "external_codes", :action => "new"}
    end
  
    it "should generate params { :controller => 'external_codes', action => 'create' } from POST /external_codes" do
      params_from(:post, "/external_codes").should == {:controller => "external_codes", :action => "create"}
    end
  
    it "should generate params { :controller => 'external_codes', action => 'show', id => '1' } from GET /external_codes/1" do
      params_from(:get, "/external_codes/1").should == {:controller => "external_codes", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'external_codes', action => 'edit', id => '1' } from GET /external_codes/1;edit" do
      params_from(:get, "/external_codes/1/edit").should == {:controller => "external_codes", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'external_codes', action => 'update', id => '1' } from PUT /external_codes/1" do
      params_from(:put, "/external_codes/1").should == {:controller => "external_codes", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'external_codes', action => 'destroy', id => '1' } from DELETE /external_codes/1" do
      params_from(:delete, "/external_codes/1").should == {:controller => "external_codes", :action => "destroy", :id => "1"}
    end
  end
end