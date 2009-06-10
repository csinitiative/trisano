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

describe Place do

  fixtures :places, :places_types

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

  describe "finding exising places" do
    fixtures :codes, :places, :places_types
    
    it "should be able to find 'Unassigned' jurisdiction by name" do
      Place.jurisdiction_by_name('Unassigned').should_not be_nil
    end

  end

  describe "class method" do
    it "hospitals should return a list of hospitals" do
      h = Place.hospitals
      h.length.should == 3
      h[0].should == places(:AVH)
      h[1].should == places(:BRVH)
      h[2].should == places(:BRVH2)
    end

    it "hospitals should return a list of hospitals with no duplicate names" do
      h = Place.hospitals(true)
      h.length.should == 2
      h[0].should == places(:AVH)
      h[1].should == places(:BRVH)
    end

    it "jurisdictions should return a list of jurisdictions" do
      h = Place.jurisdictions
      h.length.should == 4
    end
  end

  describe 'multiple place types' do
    before :each do
      @place = Place.new(:name => 'Metroid')
      @place.place_types << codes(:place_type_hospital)
      @place.place_types << codes(:place_type_lab)
    end

    it 'should make a valid description' do
      @place.save
      @place.place_types.size.should == 2
      @place.formatted_place_descriptions.should == 'Hospital / ICP and Laboratory'
    end

  end

end

