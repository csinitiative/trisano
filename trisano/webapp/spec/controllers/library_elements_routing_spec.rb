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

describe LibraryElementsController do
  describe "route generation" do

    it "should map { :controller => 'library_elements', :action => 'index' } to /library_elements" do
      route_for(:controller => "library_elements", :action => "index").should == "/library_elements"
    end
    
    it "should map { :controller => 'library_elements', :action => 'export' } to /library_elements/export" do
      route_for(:controller => "library_elements", :action => "export").should == "/library_elements/export"
    end
    
    it "should map { :controller => 'library_elements', :action => 'import'} to /library_elements/import" do
      route_for(:controller => "library_elements", :action => "import").should == "/library_elements/import"
    end
    
  end

  describe "route recognition" do

    it "should generate params { :controller => 'library_elements', action => 'index' } from GET /library_elements" do
      params_from(:get, "/library_elements").should == {:controller => "library_elements", :action => "index"}
    end
    
    it "should generate params { :controller => 'library_elements', action => 'export' } from POST /library_elements/export" do
      params_from(:post, "/library_elements/export").should == {:controller => "library_elements", :action => "export" }
    end
    
    it "should generate params { :controller => 'library_elements', action => 'import' } from POST /library_elements/import" do
      params_from(:post, "/library_elements/import").should == {:controller => "library_elements", :action => "import"}
    end
    
  end
end