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

describe EntitiesController do
  describe "route generation" do

    it "should map { :controller => 'entities', :action => 'index' } to /entities" do
      route_for(:controller => "entities", :action => "index").should == "/entities"
    end
  
    it "should map { :controller => 'entities', :action => 'new' } to /entities/new" do
      route_for(:controller => "entities", :action => "new").should == "/entities/new"
    end
  
    it "should map { :controller => 'entities', :action => 'show', :id => 1 } to /entities/1" do
      route_for(:controller => "entities", :action => "show", :id => 1).should == "/entities/1"
    end
  
    it "should map { :controller => 'entities', :action => 'edit', :id => 1 } to /entities/1/edit" do
      route_for(:controller => "entities", :action => "edit", :id => 1).should == "/entities/1/edit"
    end
  
    it "should map { :controller => 'entities', :action => 'update', :id => 1} to /entities/1" do
      route_for(:controller => "entities", :action => "update", :id => 1).should == "/entities/1"
    end
  
    it "should map { :controller => 'entities', :action => 'destroy', :id => 1} to /entities/1" do
      route_for(:controller => "entities", :action => "destroy", :id => 1).should == "/entities/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'entities', action => 'index' } from GET /entities" do
      params_from(:get, "/entities").should == {:controller => "entities", :action => "index"}
    end
  
    it "should generate params { :controller => 'entities', action => 'new' } from GET /entities/new" do
      params_from(:get, "/entities/new").should == {:controller => "entities", :action => "new"}
    end
  
    it "should generate params { :controller => 'entities', action => 'create' } from POST /entities" do
      params_from(:post, "/entities").should == {:controller => "entities", :action => "create"}
    end
  
    it "should generate params { :controller => 'entities', action => 'show', id => '1' } from GET /entities/1" do
      params_from(:get, "/entities/1").should == {:controller => "entities", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'entities', action => 'edit', id => '1' } from GET /entities/1;edit" do
      params_from(:get, "/entities/1/edit").should == {:controller => "entities", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'entities', action => 'update', id => '1' } from PUT /entities/1" do
      params_from(:put, "/entities/1").should == {:controller => "entities", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'entities', action => 'destroy', id => '1' } from DELETE /entities/1" do
      params_from(:delete, "/entities/1").should == {:controller => "entities", :action => "destroy", :id => "1"}
    end
  end
end
