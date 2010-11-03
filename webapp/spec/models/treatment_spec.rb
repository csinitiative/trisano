# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

describe Treatment do

  describe "returning treatments" do

    describe "by type" do

      before(:each) do
        @treatment_type_one = Factory.create(:treatment_type, :the_code => "TT1", :code_description => "Treatment Type 1")
        @treatment_type_two = Factory.create(:treatment_type, :the_code => "TT2", :code_description => "Treatment Type 2")
        @treatment_type_three = Factory.create(:treatment_type, :the_code => "TT3", :code_description => "Treatment Type 2")

        @treatment_type_one_first = Factory.create(:treatment, :treatment_type => @treatment_type_one)
        @treatment_type_one_second = Factory.create(:treatment, :treatment_type => @treatment_type_one)
        @treatment_type_one_third = Factory.create(:treatment, :treatment_type => @treatment_type_one)

        @treatment_type_two_first = Factory.create(:treatment, :treatment_type => @treatment_type_two)
        @treatment_type_two_second = Factory.create(:treatment, :treatment_type => @treatment_type_two)
      end

      it "should raise an error if not passed a code" do
        lambda { Treatment.all_by_type("TT1") }.should raise_error(ArgumentError)
      end

      it "should return treatments by treatment type" do
        Treatment.all_by_type(@treatment_type_one).size.should == 3
        Treatment.all_by_type(@treatment_type_two).size.should == 2
        Treatment.all_by_type(@treatment_type_three).size.should == 0
      end
    end

    describe "by active treatments" do
      before(:each) do
        @active_treatment_one = Factory.create(:treatment, :active => true)
        @active_treatment_two = Factory.create(:treatment, :active => true)
        @inactive_treatment = Factory.create(:treatment, :active => false)
      end

      it "should return only active treatments" do
        Treatment.active.each do |treatment|
          treatment.active.should be_true
        end
      end
    end
    
  end
  
  describe "loading" do
    before(:each) do
      @code = Factory.create(:code, :code_name => "treatment_type", :the_code => "TC", :code_description => "Test Code")

      @treatment_hashes = [
        {"treatment_type_code"=>"#{@code.the_code}", "treatment_name"=>"First Treatment"},
        {"treatment_type_code"=>"#{@code.the_code}", "treatment_name"=>"Second Treatment"}
      ]
    end

    it "should load treatments into the database" do
      lambda {Treatment.load!(@treatment_hashes)}.should change {Treatment.count}.by(2)
      Treatment.find_by_treatment_type_id_and_treatment_name(@code.id, 'First Treatment').should_not be_nil
      Treatment.find_by_treatment_type_id_and_treatment_name(@code.id, 'Second Treatment').should_not be_nil
    end

    it "should fail if an element in the hash is missing treatment_type_code" do
      @treatment_hashes << {"treatment_name"=>"Third Treatment"}
      lambda {Treatment.load!(@treatment_hashes)}.should raise_error(IndexError)
    end

    it "should fail if an element in the hash is missing treatment_name" do
      @treatment_hashes << {"treatment_type_code"=>"#{@code.the_code}"}
      lambda {Treatment.load!(@treatment_hashes)}.should raise_error(ActiveRecord::RecordInvalid)
    end

    it "should fail if the code provided is not found" do
      @treatment_hashes << {"treatment_type_code"=>"BADCODE", "treatment_name"=>"Third Treatment"}
      lambda {Treatment.load!(@treatment_hashes)}.should raise_error(RuntimeError)
    end

    it "should not fail if there are extra attributes in the hash" do
      @treatment_hashes << {"treatment_type_code"=>"#{@code.the_code}", "treatment_name"=>"Third Treatment", "extra_attribute" => "extra_stuff_needed_for_load_logic"}
      lambda {Treatment.load!(@treatment_hashes)}.should change {Treatment.count}.by(3)
    end

    it "should not change anything if the values have already been loaded" do
      lambda {Treatment.load!(@treatment_hashes)}.should change {Treatment.count}.by(2)
      lambda {Treatment.load!(@treatment_hashes)}.should change {Treatment.count}.by(0)
    end
    
  end
  
end