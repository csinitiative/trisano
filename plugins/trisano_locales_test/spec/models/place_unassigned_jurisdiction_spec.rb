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

require File.expand_path(File.dirname(__FILE__) + '/../../../../../spec/spec_helper')

describe Place, "when working with the unassigned jurisdiction" do
  include PlaceSpecHelper

  before :all do
    HospitalsParticipation.delete_all
    Participation.delete_all
    RoleMembership.delete_all
    PrivilegesRole.delete_all
    Place.delete_all
    PlaceEntity.delete_all
  end

  after :all do
    Fixtures.reset_cache
  end

  before(:each) do
    @place = Place.new
  end

  after(:all) do
    I18n.locale = :en
  end

  it "should consider a place with the name 'Unassigned' and a place type of 'J' as the unassigned jurisdiction" do
    @place = Factory.create(:place, :name => "Unassigned", :short_name => "Unassigned")
    @place.place_types << Code.jurisdiction_place_type
    @place.is_unassigned_jurisdiction?.should be_true
  end

  it "should not consider a place with the name 'Unassigned' but without a place type of 'J' as the unassigned jurisdiction" do
    @place = Factory.create(:place, :name => "Unassigned", :short_name => "Unassigned")
    @place.is_unassigned_jurisdiction?.should be_false
  end

  it "should not consider a place without the name 'Unassigned' but with a place type of 'J' as the unassigned jurisdiction" do
    @place = Factory.create(:place, :name => "SW Jurisdiction", :short_name => "SWJ")
    @place.place_types << Code.jurisdiction_place_type
    @place.is_unassigned_jurisdiction?.should be_false
  end

  it "should not consider a place without the name 'Unassigned' and without a place type of 'J' as the unassigned jurisdiction" do
    @place = Factory.create(:place, :name => "SW Jurisdiction", :short_name => "SWJ")
    @place.is_unassigned_jurisdiction?.should be_false
  end

  it "should display 'Unassigned' for the name when using the :en locale" do
    @place = Factory.create(:place, :name => "Unassigned", :short_name => "Unassigned")

    @place.place_types << Code.jurisdiction_place_type
    I18n.locale = :en
    @place.name.should == "Unassigned"
  end

  it "should display 'xUnassigned' for the name when using the :test locale" do
    @place = Factory.create(:place, :name => "Unassigned", :short_name => "Unassigned")

    @place.place_types << Code.jurisdiction_place_type
    I18n.locale = :test
    @place.name.should == "xUnassigned"
  end

  it "should display 'Unassigned' for the short name when using the :en locale" do
    @place = Factory.create(:place, :name => "Unassigned", :short_name => "Unassigned")
    @place.place_types << Code.jurisdiction_place_type
    I18n.locale = :en
    @place.short_name.should == "Unassigned"
  end

  it "should display 'xUnassigned' for the name when using the :test locale" do
    @place = Factory.create(:place, :name => "Unassigned", :short_name => "Unassigned")
    @place.place_types << Code.jurisdiction_place_type
    I18n.locale = :test
    @place.short_name.should == "xUnassigned"
  end

  it "should be able to place 'xUnassigned' at the top of the list in the test locale" do
    create_jurisdiction_entity
    create_jurisdiction_entity(:place_attributes => { :name => "Unassigned", :short_name => "Unassigned" })
    I18n.locale = :test
    jurisdictions = put_unassigned_at_the_bottom(Place.jurisdictions)
    Place.pull_unassigned_and_put_it_on_top(jurisdictions).first.name.should == "xUnassigned"
  end

end

