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

describe ExternalCodesController do
  describe "route generation" do

    it "should map { :controller => 'external_codes', :action => 'index' } to /codes" do
      route_for(:controller => "external_codes", :action => "index").should == "/codes"
    end

    it "should map { :controller => 'external_codes', :action => 'index_code', :code_name => 'case' } to /codes/case" do
      route_for(:controller => "external_codes", :action => "index_code", :code_name => 'case').should == "/codes/case"
    end

    it "should map { :controller => 'external_codes', :action => 'create_code', :code_name => 'case' } to /codes/case" do
      route_for(:controller => "external_codes", :action => "create_code", :code_name => 'case').should == "/codes/case"
    end

    it "should map { :controller => 'external_codes', :action => 'new_code', :code_name => 'case' } to /codes/case/new" do
      route_for(:controller => "external_codes", :action => "new_code", :code_name => 'case').should == "/codes/case/new"
    end

    it "should map { :controller => 'external_codes', :action => 'show_code', :code_name => 'case', :the_code => 'UNK' } to /codes/case/UNK" do
      route_for(:controller => "external_codes", :action => "show_code", :code_name => 'case', :the_code => 'UNK').should == "/codes/case/UNK"
    end

    it "should map { :controller => 'external_codes', :action => 'update_code', :code_name => 'case', :the_code => 'UNK' } to /codes/case/UNK" do
      route_for(:controller => "external_codes", :action => "update_code", :code_name => 'case', :the_code => 'UNK').should == "/codes/case/UNK"
    end

    it "should map { :controller => 'external_codes', :action => 'edit_code', :code_name => 'case', :the_code => 'UNK' } to /codes/case/UNK/edit" do
      route_for(:controller => "external_codes", :action => "edit_code", :code_name => 'case', :the_code => 'UNK').should == "/codes/case/UNK/edit"
    end

    it "should map { :controller => 'external_codes', :action => 'soft_delete_code', :code_name => 'case', :the_code => 'UNK' } to /codes/case/UNK/soft_delete" do
      route_for(:controller => "external_codes", :action => "soft_delete_code", :code_name => 'case', :the_code => 'UNK').should == "/codes/case/UNK/soft_delete"
    end

    it "should map { :controller => 'external_codes', :action => 'soft_undelete_code', :code_name => 'case', :the_code => 'UNK' } to /codes/case/UNK/soft_undelete" do
      route_for(:controller => "external_codes", :action => "soft_undelete_code", :code_name => 'case', :the_code => 'UNK').should == "/codes/case/UNK/soft_undelete"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'external_codes', action => 'index' } from GET /codes" do
      params_from(:get, "/codes").should == {:controller => "external_codes", :action => "index"}
    end

    it "should generate params { :controller => 'external_codes', action => 'index_code', :code_name => 'case' } from GET /codes/case" do
      params_from(:get, "/codes/case").should == {:controller => "external_codes", :action => "index_code", :code_name => 'case'}
    end

    it "should generate params { :controller => 'external_codes', action => 'create_code', :code_name => 'case' } from GET /codes/case" do
      params_from(:post, "/codes/case").should == {:controller => "external_codes", :action => "create_code", :code_name => 'case'}
    end

    it "should generate params { :controller => 'external_codes', action => 'new_code', :code_name => 'case' } from GET /codes/case/new" do
      params_from(:get, "/codes/case/new").should == {:controller => "external_codes", :action => "new_code", :code_name => 'case'}
    end

    it "should generate params { :controller => 'external_codes', action => 'show_code', :code_name => 'case', :code_name => 'case', :the_code => 'UNK' } from GET /codes/case/UNK" do
      params_from(:get, "/codes/case/UNK").should == {:controller => "external_codes", :action => "show_code", :code_name => 'case', :the_code => 'UNK'}
    end

    it "should generate params { :controller => 'external_codes', action => 'update_code', :code_name => 'case', :code_name => 'case', :the_code => 'UNK' } from GET /codes/case/UNK" do
      params_from(:post, "/codes/case/UNK").should == {:controller => "external_codes", :action => "update_code", :code_name => 'case', :the_code => 'UNK'}
    end

    it "should generate params { :controller => 'external_codes', action => 'edit_code', :code_name => 'case', :code_name => 'case', :the_code => 'UNK' } from GET /codes/case/UNK/edit" do
      params_from(:get, "/codes/case/UNK/edit").should == {:controller => "external_codes", :action => "edit_code", :code_name => 'case', :the_code => 'UNK'}
    end

    it "should generate params { :controller => 'external_codes', action => 'soft_delete_code', :code_name => 'case', :code_name => 'case', :the_code => 'UNK' } from GET /codes/case/UNK/soft_delete" do
      params_from(:get, "/codes/case/UNK/soft_delete").should == {:controller => "external_codes", :action => "soft_delete_code", :code_name => 'case', :the_code => 'UNK'}
    end

    it "should generate params { :controller => 'external_codes', action => 'soft_undelete_code', :code_name => 'case', :code_name => 'case', :the_code => 'UNK' } from GET /codes/case/UNK/soft_undelete" do
      params_from(:get, "/codes/case/UNK/soft_undelete").should == {:controller => "external_codes", :action => "soft_undelete_code", :code_name => 'case', :the_code => 'UNK'}
    end
  end
end
