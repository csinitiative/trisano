# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

  fixtures :places, :entities, :places_types

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

    describe "as a jurisdiction" do
      before(:each) do
        @jurisdiction_place_type = create_jurisdiction_place_type
        @place.place_types << @jurisdiction_place_type
      end

      it "should be invalid without a short name" do
        @place.should_not be_valid
      end

      it "should be valid with a short name" do
        @place.short_name = "whatever"
        @place.should_not be_valid
      end

    end

  end

  describe "finding exising places" do
    fixtures :codes, :places

    it "should be able to find 'Unassigned' jurisdiction by name" do
      Place.jurisdiction_by_name('Unassigned').should_not be_nil
    end

    it "should be able to find 'Unassigned' jurisdiction by with the helper" do
      unassigned_jurisdiction = Place.unassigned_jurisdiction
      unassigned_jurisdiction.should_not be_nil
      unassigned_jurisdiction.name.should == "Unassigned"
    end
  end

  describe "when listing jurisdictions" do

    after(:all) do
      I18n.locale = :en
    end

    it "should be able to place 'Unassigned' at the top of the list" do
      jurisdictions = put_unassigned_at_the_bottom(Place.jurisdictions)
      Place.pull_unassigned_and_put_it_on_top(jurisdictions).first.name.should == "Unassigned"
    end

  end

  describe "class method" do

    describe "hospitals" do
      it "should return a list of hospitals" do
        h = Place.hospitals
        h.length.should == 3
        h[0].name.should == places(:AVH).name
        h[1].name.should == places(:BRVH).name
        h[2].name.should == places(:BRVH2).name
      end

      it "should return a list of hospitals with no duplicate names" do
        h = Place.hospitals(true)
        h.length.should == 2
        h[0].name.should == places(:AVH).name
        h[1].name.should == places(:BRVH).name
      end

      it "should not return deleted hospitals" do
        @hospital_to_delete = places(:AVH)
        @hospital_to_delete.entity.deleted_at = Time.now
        @hospital_to_delete.entity.save!
        h = Place.hospitals
        h.length.should == 2

        # Setting back to un-deleted to avoid future fixture panic until this is factoried up
        @hospital_to_delete.entity.deleted_at = nil
        @hospital_to_delete.entity.save!
      end
    end

    describe "reporting_agencies" do

      it "should return active reporting agencies" do
        place_to_find = create_reporting_agency!("Zack's Reporting Agency Shack")
        Place.reporting_agencies_by_name("Zack's Reporting Agency Shack").first.should == place_to_find.place
      end

      it "should do a starts-with search" do
        place_to_find = create_reporting_agency!("Zack's Reporting Agency Shack")
        another_place_to_find = create_reporting_agency!("Zack's Zippy Reporting Agency Shack")
        reporting_agencies = Place.reporting_agencies_by_name("Zack's")
        [place_to_find, another_place_to_find].each do |place_entity|
          reporting_agencies.include?(place_entity.place).should be_true
        end
      end

      it "should not return soft-deleted reporting agencies" do
        place_to_find = create_reporting_agency!("Zack's Reporting Agency Shack")
        place_to_find.update_attribute(:deleted_at, Time.now)
        Place.reporting_agencies_by_name("Zack's Reporting Agency Shack").empty?.should be_true
      end
    end

    describe "jurisdictions" do
      it "should return a list of jurisdictions" do
        h = Place.jurisdictions
        h.length.should == 5
      end

      it "should not return deleted jurisdictions" do
        @jurisdiction_to_delete = places(:Southeastern_District)
        @jurisdiction_to_delete.entity.deleted_at = Time.now
        @jurisdiction_to_delete.entity.save!
        h = Place.jurisdictions
        h.length.should == 4

        # Setting back to un-deleted to avoid future fixture panic until this is factoried up
        @jurisdiction_to_delete.entity.deleted_at = nil
        @jurisdiction_to_delete.entity.save!
      end
    end

    it "exposed_types should return all place type codes minus the juridsdiction type" do
      # Ensure there's a jurisdiction type
      Code.find_by_code_name_and_the_code("placetype", "J").should_not be_nil

      types = Place.exposed_types
      types.size.should > 0
      types.each do |code|
        code.the_code.should_not == "J"
      end
    end

  end

  describe 'multiple place types' do
    before :each do
      @place = Place.new(:name => 'Metroid')
      @place.place_types << codes(:place_type_hospital)
      @place.place_types << codes(:place_type_lab)
      @place.save!
    end

    it 'should make a valid description' do
      @place.place_types.size.should == 2
      @place.formatted_place_descriptions.should == 'Hospital / ICP and Laboratory'
    end
  end

  describe 'place codes i18n' do
    before do
      @place_type1 = Factory.create(:place_type, :code_description => 'one')
      @place_type1.code_translations.build(:locale => 'test', :code_description => 'Zed')
      @place_type1.save!

      @place_type2 = Factory.create(:place_type, :code_description => 'two')
      @place_type2.code_translations.build(:locale => 'test', :code_description => 'Dead')
      @place_type2.save!

      @place = Factory.build(:place, :short_name => 'not blank')
      @place.place_types << @place_type1
      @place.place_types << @place_type2
      @place.save!
    end

    after do
      I18n.locale = :en
    end

    it 'should sort place types based on translated code description' do
      @place.reload
      @place.place_types.all(:order => 'code_description').collect(&:code_description).should == ['one', 'two']
      I18n.locale = :test
      @place.reload
      @place.place_types.all(:order => 'code_description').collect(&:code_description).should == ['Dead', 'Zed']
    end

  end

  describe "'Unassigned' is special for jurisdiction places" do
    before do
      destroy_fixture_data
      create_unassigned_jurisdiction_entity
    end

    after { Fixtures.reset_cache }

    it "should not be possible to create a second 'Unassigned' jurisdiction" do
      Place.jurisdiction_by_name('Unassigned').should_not be_nil
      place = Place.create(:name => 'Unassigned', :place_type_ids => [Code.jurisdiction_place_type_id])
      place.errors.on(:name).should == "'Unassigned' is special for jurisdictions. Please choose a different name."
    end
  end

end

