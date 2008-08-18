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

describe FormsController do
  describe "route generation" do

    it "should map { :controller => 'forms', :action => 'index' } to /forms" do
      route_for(:controller => "forms", :action => "index").should == "/forms"
    end
  
    it "should map { :controller => 'forms', :action => 'new' } to /forms/new" do
      route_for(:controller => "forms", :action => "new").should == "/forms/new"
    end
  
    it "should map { :controller => 'forms', :action => 'show', :id => 1 } to /forms/1" do
      route_for(:controller => "forms", :action => "show", :id => 1).should == "/forms/1"
    end
  
    it "should map { :controller => 'forms', :action => 'edit', :id => 1 } to /forms/1/edit" do
      route_for(:controller => "forms", :action => "edit", :id => 1).should == "/forms/1/edit"
    end
  
    it "should map { :controller => 'forms', :action => 'update', :id => 1} to /forms/1" do
      route_for(:controller => "forms", :action => "update", :id => 1).should == "/forms/1"
    end
  
    it "should map { :controller => 'forms', :action => 'destroy', :id => 1} to /forms/1" do
      route_for(:controller => "forms", :action => "destroy", :id => 1).should == "/forms/1"
    end
    
    it "should map { :controller => 'forms', :action => 'builder', :id => 1} to /forms/builder/1" do
      route_for(:controller => "forms", :action => "builder", :id => 1).should == "/forms/builder/1"
    end
    
    it "should map { :controller => 'forms', :action => 'publish', :id => 1} to /forms/publish/1" do
      route_for(:controller => "forms", :action => "publish", :id => 1).should == "/forms/publish/1"
    end
    
    it "should map { :controller => 'forms', :action => 'library_admin', :type => 'question_element'} to /forms/library_admin/question_element" do
      route_for(:controller => "forms", :action => "library_admin", :type => 'question_element').should == "/forms/library_admin/question_element"
    end
    
  end

  describe "route recognition" do

    it "should generate params { :controller => 'forms', action => 'index' } from GET /forms" do
      params_from(:get, "/forms").should == {:controller => "forms", :action => "index"}
    end
  
    it "should generate params { :controller => 'forms', action => 'new' } from GET /forms/new" do
      params_from(:get, "/forms/new").should == {:controller => "forms", :action => "new"}
    end
  
    it "should generate params { :controller => 'forms', action => 'create' } from POST /forms" do
      params_from(:post, "/forms").should == {:controller => "forms", :action => "create"}
    end
  
    it "should generate params { :controller => 'forms', action => 'show', id => '1' } from GET /forms/1" do
      params_from(:get, "/forms/1").should == {:controller => "forms", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'forms', action => 'edit', id => '1' } from GET /forms/1;edit" do
      params_from(:get, "/forms/1/edit").should == {:controller => "forms", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'forms', action => 'update', id => '1' } from PUT /forms/1" do
      params_from(:put, "/forms/1").should == {:controller => "forms", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'forms', action => 'destroy', id => '1' } from DELETE /forms/1" do
      params_from(:delete, "/forms/1").should == {:controller => "forms", :action => "destroy", :id => "1"}
    end
    
    it "should generate params { :controller => 'forms', action => 'builder', id => '1' } from GET /forms/builder/1" do
      params_from(:get, "/forms/builder/1").should == {:controller => "forms", :action => "builder", :id => "1"}
    end
    
    it "should generate params { :controller => 'forms', action => 'publish', id => '1' } from POST /forms/publish/1" do
      params_from(:post, "/forms/publish/1").should == {:controller => "forms", :action => "publish", :id => "1"}
    end
    
    it "should generate params { :controller => 'forms', action => 'library_admin', type => 'question_element' } from POST /forms/library_admin/question_element" do
      params_from(:post, "/forms/library_admin/question_element").should == {:controller => "forms", :action => "library_admin", :type => "question_element"}
    end
    
    
  end
end