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

describe FollowUpElementsController do
  describe "route generation" do

    it "should map { :controller => 'follow_up_elements', :action => 'index' } to /follow_up_elements" do
      route_for(:controller => "follow_up_elements", :action => "index").should == "/follow_up_elements"
    end
  
    it "should map { :controller => 'follow_up_elements', :action => 'new' } to /follow_up_elements/new" do
      route_for(:controller => "follow_up_elements", :action => "new").should == "/follow_up_elements/new"
    end
  
    it "should map { :controller => 'follow_up_elements', :action => 'show', :id => 1 } to /follow_up_elements/1" do
      route_for(:controller => "follow_up_elements", :action => "show", :id => 1).should == "/follow_up_elements/1"
    end
  
    it "should map { :controller => 'follow_up_elements', :action => 'edit', :id => 1 } to /follow_up_elements/1/edit" do
      route_for(:controller => "follow_up_elements", :action => "edit", :id => 1).should == "/follow_up_elements/1/edit"
    end
  
    it "should map { :controller => 'follow_up_elements', :action => 'update', :id => 1} to /follow_up_elements/1" do
      route_for(:controller => "follow_up_elements", :action => "update", :id => 1).should == "/follow_up_elements/1"
    end
  
    it "should map { :controller => 'follow_up_elements', :action => 'destroy', :id => 1} to /follow_up_elements/1" do
      route_for(:controller => "follow_up_elements", :action => "destroy", :id => 1).should == "/follow_up_elements/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'follow_up_elements', action => 'index' } from GET /follow_up_elements" do
      params_from(:get, "/follow_up_elements").should == {:controller => "follow_up_elements", :action => "index"}
    end
  
    it "should generate params { :controller => 'follow_up_elements', action => 'new' } from GET /follow_up_elements/new" do
      params_from(:get, "/follow_up_elements/new").should == {:controller => "follow_up_elements", :action => "new"}
    end
  
    it "should generate params { :controller => 'follow_up_elements', action => 'create' } from POST /follow_up_elements" do
      params_from(:post, "/follow_up_elements").should == {:controller => "follow_up_elements", :action => "create"}
    end
  
    it "should generate params { :controller => 'follow_up_elements', action => 'show', id => '1' } from GET /follow_up_elements/1" do
      params_from(:get, "/follow_up_elements/1").should == {:controller => "follow_up_elements", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'follow_up_elements', action => 'edit', id => '1' } from GET /follow_up_elements/1;edit" do
      params_from(:get, "/follow_up_elements/1/edit").should == {:controller => "follow_up_elements", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'follow_up_elements', action => 'update', id => '1' } from PUT /follow_up_elements/1" do
      params_from(:put, "/follow_up_elements/1").should == {:controller => "follow_up_elements", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'follow_up_elements', action => 'destroy', id => '1' } from DELETE /follow_up_elements/1" do
      params_from(:delete, "/follow_up_elements/1").should == {:controller => "follow_up_elements", :action => "destroy", :id => "1"}
    end
  end
end