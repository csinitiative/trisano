# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

describe UsersController do
  describe "route generation" do

    it "should map { :controller => 'users', :action => 'index' } to /users" do
      route_for(:controller => "users", :action => "index").should == "/users"
    end
  
    it "should map { :controller => 'users', :action => 'new' } to /users/new" do
      route_for(:controller => "users", :action => "new").should == "/users/new"
    end
  
    it "should map { :controller => 'users', :action => 'show', :id => 1 } to /users/1" do
      route_for(:controller => "users", :action => "show", :id => 1).should == "/users/1"
    end
  
    it "should map { :controller => 'users', :action => 'edit', :id => 1 } to /users/1/edit" do
      route_for(:controller => "users", :action => "edit", :id => 1).should == "/users/1/edit"
    end
  
    it "should map { :controller => 'users', :action => 'update', :id => 1} to /users/1" do
      route_for(:controller => "users", :action => "update", :id => 1).should == "/users/1"
    end
  
    it "should map { :controller => 'users', :action => 'destroy', :id => 1} to /users/1" do
      route_for(:controller => "users", :action => "destroy", :id => 1).should == "/users/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'users', action => 'index' } from GET /users" do
      params_from(:get, "/users").should == {:controller => "users", :action => "index"}
    end
  
    it "should generate params { :controller => 'users', action => 'new' } from GET /users/new" do
      params_from(:get, "/users/new").should == {:controller => "users", :action => "new"}
    end
  
    it "should generate params { :controller => 'users', action => 'create' } from POST /users" do
      params_from(:post, "/users").should == {:controller => "users", :action => "create"}
    end
  
    it "should generate params { :controller => 'users', action => 'show', id => '1' } from GET /users/1" do
      params_from(:get, "/users/1").should == {:controller => "users", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'users', action => 'edit', id => '1' } from GET /users/1;edit" do
      params_from(:get, "/users/1/edit").should == {:controller => "users", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'users', action => 'update', id => '1' } from PUT /users/1" do
      params_from(:put, "/users/1").should == {:controller => "users", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'users', action => 'destroy', id => '1' } from DELETE /users/1" do
      params_from(:delete, "/users/1").should == {:controller => "users", :action => "destroy", :id => "1"}
    end
  end
end