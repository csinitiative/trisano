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

describe Treatment do

  before(:all) do
    destroy_fixture_data
  end

  after(:all) do
    Fixtures.reset_cache
  end

  it { should have_many(:diseases) }
  it { should have_many(:disease_specific_treatments) }
  it { should validate_presence_of(:treatment_name) }

  it "validates uniqueness of the treatment name" do
    Factory(:treatment, :treatment_name => 'lobotomy')
    lambda { Factory(:treatment, :treatment_name => 'lobotomy') }.should raise_error
    Factory.build(:treatment, :treatment_name => 'lobotomy').should_not be_valid
  end

  describe "returning treatments" do

    describe "by type" do

      before(:each) do
        @treatment_type_one = Factory.create(:treatment_type, :the_code => "TT1", :code_description => "Treatment Type 1")
        @treatment_type_two = Factory.create(:treatment_type, :the_code => "TT2", :code_description => "Treatment Type 2")
        @treatment_type_three = Factory.create(:treatment_type, :the_code => "TT3", :code_description => "Treatment Type 3")

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
        @active_treatment_one = Factory.create(:treatment, :treatment_name => "B Treatment", :active => true)
        @active_treatment_two = Factory.create(:treatment, :treatment_name => "A Treatment", :active => true)
        @inactive_treatment = Factory.create(:treatment, :treatment_name => "C Treatment", :active => false)
      end

      it "should return only active treatments" do
        Treatment.active.each do |treatment|
          treatment.active.should be_true
        end
      end

      it "should return only active treatments in alphabetical order" do
        active_treatments = Treatment.active
        active_treatments.index(Treatment.find_by_treatment_name("B Treatment")).should > active_treatments.index(Treatment.find_by_treatment_name("A Treatment"))
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

  describe "merging duplicate treatments" do

    before(:each) do
      @good_treatment = Factory.create(:treatment, :treatment_name => "Foot rubbings")
      @dupe_treatment_one = Factory.create(:treatment, :treatment_name => "Foot rubbingz")
      @dupe_treatment_two = Factory.create(:treatment, :treatment_name => "Foot rubbingzz")

      @pt_using_good_treatment = Factory.create(:participations_treatment, :treatment => @good_treatment)
      @pt_using_dupe_one = Factory.create(:participations_treatment, :treatment => @dupe_treatment_one)
      @pt_using_dupe_two = Factory.create(:participations_treatment, :treatment => @dupe_treatment_two)
    end

    it "should return true on success" do
      @good_treatment.merge([@dupe_treatment_one.id, @dupe_treatment_two.id]).should be_true
    end

    it "should point the participations_treatments using the other treatments to this treatment" do
      @good_treatment.merge([@dupe_treatment_one.id, @dupe_treatment_two.id]).should be_true
      @pt_using_dupe_one.reload
      @pt_using_dupe_two.reload

      @pt_using_dupe_one.treatment.should == @good_treatment
      @pt_using_dupe_two.treatment.should == @good_treatment
    end

    it "should delete the duplicate treatments" do
      @good_treatment.merge([@dupe_treatment_one.id, @dupe_treatment_two.id]).should be_true
      Treatment.find_by_id(@good_treatment.id).should_not be_nil
      Treatment.find_by_id(@dupe_treatment_one.id).should be_nil
      Treatment.find_by_id(@dupe_treatment_two.id).should be_nil
    end

    it "should return nil if there was an error" do
      @good_treatment.merge(0).should be_nil
    end

    it "should add an error to the treatment errors if there was an error" do
      @good_treatment.merge(0).should be_nil
      @good_treatment.errors.on(:base).should =~ /Merge failed./
    end

    it "should return nil with an error on the treatment if it was not provided any merge ids" do
      @good_treatment.merge(0).should be_nil
      @good_treatment.errors.empty?.should be_false
    end

    it "should return nil with an error if the treatment is provided with itself for merging" do
      @good_treatment.merge(@good_treatment.id).should be_nil
      @good_treatment.errors[:base].should =~ /Cannot merge a treatment into itself./
    end

    it "should return nill with an error if provided with an empty array" do
      @good_treatment.merge([]).should be_nil
      @good_treatment.errors[:base].should =~ /Unable to merge treatments: No treatments were provided for merging./
    end

  end

end
