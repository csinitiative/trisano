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

describe CoreFieldElementsController do
  describe "route generation" do

    it "should map { :controller => 'core_field_elements', :action => 'index' } to /core_field_elements" do
      route_for(:controller => "core_field_elements", :action => "index").should == "/core_field_elements"
    end
  
    it "should map { :controller => 'core_field_elements', :action => 'new' } to /core_field_elements/new" do
      route_for(:controller => "core_field_elements", :action => "new").should == "/core_field_elements/new"
    end
  
    it "should map { :controller => 'core_field_elements', :action => 'show', :id => 1 } to /core_field_elements/1" do
      route_for(:controller => "core_field_elements", :action => "show", :id => 1).should == "/core_field_elements/1"
    end
  
    it "should map { :controller => 'core_field_elements', :action => 'edit', :id => 1 } to /core_field_elements/1/edit" do
      route_for(:controller => "core_field_elements", :action => "edit", :id => 1).should == "/core_field_elements/1/edit"
    end
  
    it "should map { :controller => 'core_field_elements', :action => 'update', :id => 1} to /core_field_elements/1" do
      route_for(:controller => "core_field_elements", :action => "update", :id => 1).should == "/core_field_elements/1"
    end
  
    it "should map { :controller => 'core_field_elements', :action => 'destroy', :id => 1} to /core_field_elements/1" do
      route_for(:controller => "core_field_elements", :action => "destroy", :id => 1).should == "/core_field_elements/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'core_field_elements', action => 'index' } from GET /core_field_elements" do
      params_from(:get, "/core_field_elements").should == {:controller => "core_field_elements", :action => "index"}
    end
  
    it "should generate params { :controller => 'core_field_elements', action => 'new' } from GET /core_field_elements/new" do
      params_from(:get, "/core_field_elements/new").should == {:controller => "core_field_elements", :action => "new"}
    end
  
    it "should generate params { :controller => 'core_field_elements', action => 'create' } from POST /core_field_elements" do
      params_from(:post, "/core_field_elements").should == {:controller => "core_field_elements", :action => "create"}
    end
  
    it "should generate params { :controller => 'core_field_elements', action => 'show', id => '1' } from GET /core_field_elements/1" do
      params_from(:get, "/core_field_elements/1").should == {:controller => "core_field_elements", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'core_field_elements', action => 'edit', id => '1' } from GET /core_field_elements/1;edit" do
      params_from(:get, "/core_field_elements/1/edit").should == {:controller => "core_field_elements", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'core_field_elements', action => 'update', id => '1' } from PUT /core_field_elements/1" do
      params_from(:put, "/core_field_elements/1").should == {:controller => "core_field_elements", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'core_field_elements', action => 'destroy', id => '1' } from DELETE /core_field_elements/1" do
      params_from(:delete, "/core_field_elements/1").should == {:controller => "core_field_elements", :action => "destroy", :id => "1"}
    end
  end
end