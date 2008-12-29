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

  describe "finding exising places" do
    fixtures :codes, :places
    
    it "should be able to find 'Unassigned' jurisdiction by name" do
      Place.jurisdiction_by_name('Unassigned').should_not be_nil
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
      h.length.should == 4
    end
  end

  describe 'reporting agency types' do
    before :each do
      @place = Place.new(:name => 'Metroid', :place_type_id => Code.other_place_type_id)
      @place.reporting_agency_types << ReportingAgencyType.new(:code_id => codes(:place_type_hospital).id)
      @place.reporting_agency_types << ReportingAgencyType.new(:code_id => codes(:place_type_lab).id)
    end

    it 'should make a valid description' do
      lambda { @place.save }.should change{ReportingAgencyType.count}.by(2)
      @place.agency_types_description.should == 'Hospital / ICP and Laboratory'
    end

  end

end

