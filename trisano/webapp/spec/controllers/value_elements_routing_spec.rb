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

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ValueElementsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "value_elements", :action => "index").should == "/value_elements"
    end
  
    it "should map #new" do
      route_for(:controller => "value_elements", :action => "new").should == "/value_elements/new"
    end
  
    it "should map #show" do
      route_for(:controller => "value_elements", :action => "show", :id => 1).should == "/value_elements/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "value_elements", :action => "edit", :id => 1).should == "/value_elements/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "value_elements", :action => "update", :id => 1).should == "/value_elements/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "value_elements", :action => "destroy", :id => 1).should == "/value_elements/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/value_elements").should == {:controller => "value_elements", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/value_elements/new").should == {:controller => "value_elements", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/value_elements").should == {:controller => "value_elements", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/value_elements/1").should == {:controller => "value_elements", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/value_elements/1/edit").should == {:controller => "value_elements", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/value_elements/1").should == {:controller => "value_elements", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/value_elements/1").should == {:controller => "value_elements", :action => "destroy", :id => "1"}
    end
  end
end
