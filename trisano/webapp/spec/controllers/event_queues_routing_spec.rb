# Copyright (C) 2007, 2008, The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the terms of the
# GNU Affero General Public License as published by the Free Software Foundation, either 
# version 3 of the License, or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
# See the GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License along with TriSano. 
# If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

require File.dirname(__FILE__) + '/../spec_helper'

describe EventQueuesController do
  describe "route generation" do

    it "should map { :controller => 'event_queues', :action => 'index' } to /event_queues" do
      route_for(:controller => "event_queues", :action => "index").should == "/event_queues"
    end
  
    it "should map { :controller => 'event_queues', :action => 'new' } to /event_queues/new" do
      route_for(:controller => "event_queues", :action => "new").should == "/event_queues/new"
    end
  
    it "should map { :controller => 'event_queues', :action => 'show', :id => 1 } to /event_queues/1" do
      route_for(:controller => "event_queues", :action => "show", :id => 1).should == "/event_queues/1"
    end
  
    it "should map { :controller => 'event_queues', :action => 'edit', :id => 1 } to /event_queues/1/edit" do
      route_for(:controller => "event_queues", :action => "edit", :id => 1).should == "/event_queues/1/edit"
    end
  
    it "should map { :controller => 'event_queues', :action => 'update', :id => 1} to /event_queues/1" do
      route_for(:controller => "event_queues", :action => "update", :id => 1).should == "/event_queues/1"
    end
  
    it "should map { :controller => 'event_queues', :action => 'destroy', :id => 1} to /event_queues/1" do
      route_for(:controller => "event_queues", :action => "destroy", :id => 1).should == "/event_queues/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'event_queues', action => 'index' } from GET /event_queues" do
      params_from(:get, "/event_queues").should == {:controller => "event_queues", :action => "index"}
    end
  
    it "should generate params { :controller => 'event_queues', action => 'new' } from GET /event_queues/new" do
      params_from(:get, "/event_queues/new").should == {:controller => "event_queues", :action => "new"}
    end
  
    it "should generate params { :controller => 'event_queues', action => 'create' } from POST /event_queues" do
      params_from(:post, "/event_queues").should == {:controller => "event_queues", :action => "create"}
    end
  
    it "should generate params { :controller => 'event_queues', action => 'show', id => '1' } from GET /event_queues/1" do
      params_from(:get, "/event_queues/1").should == {:controller => "event_queues", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'event_queues', action => 'edit', id => '1' } from GET /event_queues/1;edit" do
      params_from(:get, "/event_queues/1/edit").should == {:controller => "event_queues", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'event_queues', action => 'update', id => '1' } from PUT /event_queues/1" do
      params_from(:put, "/event_queues/1").should == {:controller => "event_queues", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'event_queues', action => 'destroy', id => '1' } from DELETE /event_queues/1" do
      params_from(:delete, "/event_queues/1").should == {:controller => "event_queues", :action => "destroy", :id => "1"}
    end
  end
end
