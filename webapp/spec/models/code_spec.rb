# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

describe Code do
  before(:each) do
    @code = Code.new
  end

  it "should not be valid when empty" do
    @code.should_not be_valid
  end

  it "should be valid when populated" do
    @code.code_name = 'test'
    @code.the_code = 'TEST'
    @code.code_description = 'Test Code'
    @code.save!
    @code.should be_valid
  end

  describe 'Jurisdiction place type' do
    fixtures :codes
    it 'should exist' do
      Code.jurisdiction_place_type_id.should_not be_nil
      Code.jurisdiction_place_type.should_not be_nil
    end
  end

  describe "loading" do

    before(:each) do
      @code_name = Factory.create(:code_name, :code_name => "test_codes")
      @code_hashes = [
        {"sort_order"=>nil, "the_code"=>"TC1", "code_name"=>"#{@code_name.code_name}", "code_description"=>"Test Code 1"},
        {"sort_order"=>nil, "the_code"=>"TC2", "code_name"=>"#{@code_name.code_name}", "code_description"=>"Test Code 2"}
      ]
    end
    
    it "should load codes into the database" do
      lambda {Code.load!(@code_hashes)}.should change {Code.count}.by(2)
      Code.find_by_code_name_and_the_code(@code_name.code_name, 'TC1').should_not be_nil
      Code.find_by_code_name_and_the_code(@code_name.code_name, 'TC2').should_not be_nil
    end

    it "should fail if an element in the hash is missing code_name" do
      @code_hashes << {"sort_order"=>nil, "the_code"=>"TC3", "code_description"=>"Test Code 3"}
      lambda {Code.load!(@code_hashes)}.should raise_error(RuntimeError)
    end
    
    it "should fail if an element in the hash is missing the_code" do
      @code_hashes << {"sort_order"=>nil, "code_name"=>"#{@code_name.code_name}", "code_description"=>"Test Code 3"}
      lambda {Code.load!(@code_hashes)}.should raise_error(ActiveRecord::RecordInvalid)
    end
    
    it "should fail if an element in the hash is missing code_description" do
      @code_hashes << {"sort_order"=>nil, "the_code"=>"TC3", "code_name"=>"#{@code_name.code_name}"}
      lambda {Code.load!(@code_hashes)}.should raise_error(ActiveRecord::RecordInvalid)
    end

    it "should fail if the code name provided is not found" do
      @code_hashes << {"sort_order"=>nil, "code_name" => "missing_code_name", "the_code"=>"TC3", "code_description"=>"Test Code 3"}
      lambda {Code.load!(@code_hashes)}.should raise_error(RuntimeError)
    end

    it "should not fail if there are extra attributes in the hash" do
      @code_hashes << {"sort_order"=>nil, "code_name"=>"#{@code_name.code_name}", "the_code"=>"TC3", "code_description"=>"Test Code 3", "extra_attribute" => "extra_stuff_needed_for_load_logic"}
      lambda {Code.load!(@code_hashes)}.should change {Code.count}.by(3)
    end

    it "should not change anything if the values have already been loaded" do
      lambda {Code.load!(@code_hashes)}.should change {Code.count}.by(2)
      lambda {Code.load!(@code_hashes)}.should change {Code.count}.by(0)
    end
  end

end
