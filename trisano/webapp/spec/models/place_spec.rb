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

describe Place do

  fixtures :places

  before(:each) do
    @place = Place.new
  end

  describe "when instantiatied" do
    
    it "should be invalid without a name" do
      @place.should_not be_valid
    end

    it "should be valid with a name" do
      @place.name = "whatever"
      @place.should be_valid
    end
  end

  # The following tests are for basic activerecord functionality that would not ordinarily be tested.
  # They are here in anticipation of acts_as_auditable

  describe "when created and retrieved" do

    before(:each) do
      @place.name = "Abbott Labs"
      @place.short_name = "Abbott"
      @place.place_type = codes(:place_type_lab)
    end

    it "should add a new row" do
      lambda { @place.save }.should change { Place.count }.by(1)
    end

    it "should return what was just created" do
      @place.save
      place = Place.find_by_name("Abbott Labs")
      place.should_not be_nil
      place.name.should == "Abbott Labs"
      place.short_name.should == "Abbott"
      place.place_type.should eql(codes(:place_type_lab))
    end
  end

  describe "when updated and retrieved" do

    before(:each) do
      @place.name = "Abbott Labs"
      @place.short_name = "Abbott"
      @place.place_type = codes(:place_type_lab)
      @place.save

      @place = Place.find_by_name("Abbott Labs")
      @place.short_name = "AL"
      @place.save

      @places = Place.find_all_by_name("Abbott Labs")
      @place = @places.first
    end

    it "should return just one row" do
      @places.length.should == 1
    end

    it "should return what was just updated" do
      @place.short_name.should == "AL"
    end

    it "should maintain non-updated values" do
      @place.name.should == "Abbott Labs"
      @place.place_type.should eql(codes(:place_type_lab))
    end
  end

  describe "class method" do
    it "hospitals should return a list of hospitals" do
      h = Place.hospitals
      h.length.should == 2
      h[0].should == places(:AVH)
      h[1].should == places(:BRVH)
    end

    it "jurisdictions should return a list of jurisdictions" do
      h = Place.jurisdictions
      h.length.should == 3
    end
  end

  describe 'date of exposure' do

    it 'should be valid if nil' do
      place = Place.create(:name => 'someplace')
      place.should be_valid
    end

    it 'should accept valid dates' do
      place = Place.create(:name => 'someplace', :date_of_exposure => 'August 8, 2008')
      place.should be_valid
    end

    it 'should not accept invalid dates' do
      place = Place.create(:name => 'someplace', :date_of_exposure => 'not valid')
      place.should_not be_valid
    end
  end
end

