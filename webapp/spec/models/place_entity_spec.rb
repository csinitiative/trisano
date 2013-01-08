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

describe PlaceEntity do

  before :all do
    destroy_fixture_data
  end

  after(:all) { Fixtures.reset_cache }

  before do
    User.current_user = nil
  end

  describe "finding exising places" do

    describe "by participation" do

      describe "places used as hospitalization facilities" do
        before do
          @pool = create_place_entity!('Davis Nat', 'P')
          @event = Factory.create(:morbidity_event)
          @event.hospitalization_facilities.build(:secondary_entity_id => @pool.id).save!
        end

        it "should be found if a matching name is used" do
          psf = PlacesSearchForm.new(:name => "Davis", :place_type => "H")
          PlaceEntity.by_name_and_participation_type(psf).size.should == 1
        end

        it "should not be found if name doesn't match" do
          psf = PlacesSearchForm.new(:name => "xxx", :place_type => "H")
          PlaceEntity.by_name_and_participation_type(psf).size.should == 0
        end
      end

      describe "place used as disagnostic facilities" do
        before do
          @pool = create_place_entity!('Diagnostic Facility', 'P')
          @event = Factory.create(:morbidity_event)
          @event.diagnostic_facilities.build(:secondary_entity_id => @pool.id).save!
        end

        it "should be found if matching name is used" do
          psf = PlacesSearchForm.new(:name => "Diagnostic Facility", :place_type => "DiagnosticFacility")
          PlaceEntity.by_name_and_participation_type(psf).size.should == 1
        end

        it "should not find places that have been utilized as diagnostic facilities if a matching name is not used" do
          psf = PlacesSearchForm.new(:name => "xxx", :place_type => "DiagnosticFacility")
          PlaceEntity.by_name_and_participation_type(psf).size.should == 0
        end
      end

      describe "place used as a lab" do
        before do
          @pool = create_place_entity!('Labby Lab', 'P')
          @event = Factory.create(:morbidity_event)
          @event.labs.build(:secondary_entity_id => @pool.id).save!
        end

        it "should be found if matching name is used" do
          psf = PlacesSearchForm.new(:name => "Labby Lab", :place_type => "L")
          PlaceEntity.by_name_and_participation_type(psf).size.should == 1
        end

        it "should not be found if a matching name is not used" do
          psf = PlacesSearchForm.new(:name => "xxx", :place_type => "L")
          PlaceEntity.by_name_and_participation_type(psf).size.should == 0
        end
      end

      describe "place used as exposure" do
        before do
          @event = Factory.create(:morbidity_event)
          @event.place_child_events.build(:interested_place_attributes => {
              :place_entity_attributes => {
                  :place_attributes => {
                      :name => "FallMart"}}}).save!
        end

        it "should find places that have been utilized as place exposures if a matching name is used" do
          psf = PlacesSearchForm.new({:name => "FallMart", :place_type => "InterestedPlace"})
          PlaceEntity.by_name_and_participation_type(psf).size.should == 1
        end

        it "should not find places that have been utilized as place exposures if a matching name is not used" do
          psf = PlacesSearchForm.new({:name => "xxx", :place_type => "InterestedPlace"})
          PlaceEntity.by_name_and_participation_type(psf).size.should == 0
        end
      end

      describe "place used as a reporting agency" do
        before do
          @pool = create_place_entity!('Reporters Inc.', 'P')
          @event = Factory.create(:morbidity_event)
          @event.build_reporting_agency(:secondary_entity_id => @pool.id).save!
        end

        it "should find places that have been utilized as labs if a matching name is used" do
          psf = PlacesSearchForm.new({:name => "Reporters", :place_type => "ReportingAgency"})
          PlaceEntity.by_name_and_participation_type(psf).size.should == 1
        end

        it "should not find places that have been utilized as labs if a matching name is not used" do
          psf = PlacesSearchForm.new(:name => "xxx", :place_type => "ReportingAgency")
          PlaceEntity.by_name_and_participation_type(psf).size.should == 0
        end

        it "should be able to exclude an entity from a search result" do
          psf = PlacesSearchForm.new(:name => "Reporters", :place_type => "ReportingAgency")
          PlaceEntity.by_name_and_participation_type(psf).exclude_entity(@event.reporting_agency.place_entity).size.should == 0
        end
      end

    end

    describe "using place type" do

      before do
        destroy_fixture_data
      end

      after(:all) { Fixtures.reset_cache }

      it "should find places by thier code type" do
        p = create_place_entity!('Dark Moor', :diagnostic)
        psf = PlacesSearchForm.new(:place_type => 'H')
        PlaceEntity.by_name_and_participation_type(psf).should == [p]
      end

    end
  end

  describe "using jurisdiction named scopes" do

    before(:each) do
      @jurisdiction_one = create_jurisdiction_entity(:place_attributes => {:name => 'JurisOne'})
      @jurisdiction_two = create_jurisdiction_entity(:place_attributes => {:name => 'JurisTwo'})
      @jurisdiction_unassigned = Place.unassigned_jurisdiction.try(:entity) || create_unassigned_jurisdiction_entity
      @jurisdiction_deleted = create_jurisdiction_entity(:deleted_at => Time.now, :place_attributes => {:name => 'Baleted'})
    end

    it "should find all jurisdictions when using the 'jurisdictions' named scope" do
      PlaceEntity.jurisdictions.size.should == 4
    end

    it "should find only active jurisdictions when using the 'active_jurisdictions' named scope" do
      PlaceEntity.jurisdictions.active.size.should == 3
      PlaceEntity.jurisdictions.active.detect {|j| !j.deleted_at.nil?}.should be_nil
    end

    it "should find leave out the Unassigned jurisdiction when chaining 'excluding_unassigned' onto one of the other jurisdiction named scopes" do
      PlaceEntity.jurisdictions.excluding_unassigned.size.should == 3
      PlaceEntity.jurisdictions.excluding_unassigned.detect {|j| j.place.name == "Unassigned" }.should be_nil

      PlaceEntity.jurisdictions.active.excluding_unassigned.size.should == 2
      PlaceEntity.jurisdictions.active.excluding_unassigned.detect {|j| j.place.name == "Unassigned" }.should be_nil
    end

  end

  describe "using lab named scope" do

    before(:each) do
      @lab_name_array = ['ARUP', 'BRUP', 'CRUP', 'DRUP']
      @lab_name_array.each { |lab_name| create_place_entity!(lab_name, 'L') }

      @pool = create_place_entity!('B Pool', 'P')
      @school = create_place_entity!('A School', 'S')

      @hospital_slash_lab = create_place_entity!('Hospital Lab', 'L')
      @hospital_slash_lab.place.place_types << create_code!('placetype', 'H')

      @labs = PlaceEntity.labs
    end

    it "should include all place entities with the lab type" do
      @labs.size.should == 5 # The four lab-only labs and our one hospital/lab
      @lab_name_array.each { |lab_name| @labs.detect { |lab| lab.place.name == lab_name }.should_not be_nil }
      @labs.include?(@hospital_slash_lab).should be_true
    end

    it "should not include non-labs" do
      @labs.include?(@pool).should be_false
      @labs.include?(@school).should be_false
    end

  end

  describe "using place name convenience method" do
    before(:each) do
      @place_entity = create_place_entity!('C Pool', 'P')
    end

    it "should return the name of the place" do
      @place_entity.name.should == 'C Pool'
    end

    it "should return nil if there isn't a place associated with the place entity" do
      @place_entity.place = nil
      @place_entity.name.should be_nil
    end
  end

end
