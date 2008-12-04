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

describe Entity do
  before(:each) do
    @entity = Entity.new
  end

  #TODO: TGF:  Implment when ready
  # describe "with no associations (people, places, etc.)" do
  #   it "should be invalid" do
  #     pending "Unpend when person support is factored in"
  #   end
  # end

  describe "with an association" do
    it "should be valid to build manually" do
      #TODO: TGF CHANGE THIS BACK TO build_place WHEN ALL IS DONE
      @entity.build_place_temp(:name => "Whatever")
      @entity.entity_type = "place"
      @entity.should be_valid
    end
  end

  describe "without any associations" do
    # No entity type
    it "should not be valid" do
      @entity.should_not be_valid
    end
  end

  describe "with an associated person" do
    before(:each) do
      @entity.person = { :last_name => "Smith" }
    end

    it "should have an entity_type of person" do
      @entity.entity_type.should eql('person')
    end

    describe "where person is not valid" do
      it "should not save" do
        @entity.person = { :last_name => "" }
        @entity.save.should be_false
      end
    end

    describe "where person is valid" do
      it "should save without error" do
        @entity.person_temp.last_name = 'Lacey'
        @entity.save.should be_true
      end
    end
  end
  
  
end

describe Entity, "with associated person via custom 'person' attribute (i.e. nested hash)" do
  before(:each) do
    @entity = Entity.new( :person => {:last_name => 'Fields'} )
  end

  it "should have an entity_type of person" do
    @entity.entity_type.should eql('person')
  end

  it "person should be accesible via person attribute" do
    @entity.person.last_name.should eql("Fields")
  end

  describe "where person is not valid" do
    it "should not save" do
      @entity.person.last_name = nil
      @entity.save.should be_false
    end
  end

  describe "where person is valid" do
    it "should save without error" do
      @entity.save.should be_true
    end
  end
end

describe Entity, "with associated location and person via custom attributes" do
  before(:each) do
    @entity = Entity.new( :person => {:last_name => 'Fields'},
                          :address => {:street_name => "Pine St.", :street_number => "123" },
                          :new_telephone_attributes => [ {:entity_location_type_id => '1302', :area_code => '212', :phone_number => '5551212'} ] )
  end
    
  it "should have an entity_type of person" do
    @entity.entity_type.should eql('person')
  end

  it "person should be accesible via person attribute" do
    @entity.person.last_name.should eql("Fields")
  end

  it "address should be accesible via address attribute" do
    @entity.address.street_name.should eql("Pine St.")
  end

  it "phone number should be accesible via telephone attribute" do
    @entity.telephone.phone_number.should eql("5551212")
  end

  describe "where person is not valid" do
    it "should not save" do
      @entity.person.last_name = nil
      @entity.save.should be_false
    end
  end

  describe "where everything is valid" do

    it "should save without error" do
      @entity.save.should be_true
    end

    it "should add two new rows to the entities_location table" do
      lambda { @entity.save }.should change { EntitiesLocation.count }.by(2)
    end

    it "should add two new rows to the location table" do
      lambda { @entity.save }.should change { Location.count }.by(2)
    end

    it "should add one new row to the address table" do
      lambda { @entity.save }.should change { Address.count }.by(1)
    end
      
    it "should add one new row to the telephone table" do
      lambda { @entity.save }.should change { Telephone.count }.by(1)
    end
      
  end
end

describe Entity, "with associated location and person via empty custom attributes" do
  before(:each) do
    @entity = Entity.new( :person => {:last_name => 'Fields'},
                          :address => {},
                          :new_telephone_attributes => [ {} ] )
  end
    
  it "should save without error" do
    @entity.save.should be_true
  end

  it "should not add any rows to the entities_location table" do
    lambda { @entity.save}.should_not change { EntitiesLocation.count }
  end

  it "should not add any rows to the location table" do
    lambda { @entity.save}.should_not change { Location.count }
  end

  it "should not add any rows to the addresses table" do
    lambda { @entity.save}.should_not change { Address.count }
  end

  it "should not add any rows to the telephones table" do
    lambda { @entity.save}.should_not change { Telephone.count }
  end
end

describe Entity, "with people fixtures loaded" do
  fixtures :entities, :people, :people_races, :codes, :external_codes, :events, :participations, :disease_events, :diseases

  describe "and a single instance of Grocuho Marx" do

    it "should have a total of one person" do
      entities(:Groucho).should have(1).people
    end

    it "should have one current person named groucho" do
      entities(:Groucho).person.first_name.should eql("Groucho")
    end

  end

  describe "and multiple instances of Phil Silvers" do

    it "should have two people altogether" do
      entities(:Silvers).should have(1).people
    end

    it "should have one current person named Phil" do
      entities(:Silvers).person.first_name.should eql("Phil")
    end

    it "should have the same person for association proxy and custom attribute" do
      entities(:Silvers).person.middle_name.should eql(entities(:Silvers).person.middle_name)
    end

    it "the current instance should have a race of blank and white" do
      entities(:Silvers).races.first.should eql(external_codes(:race_black))
      entities(:Silvers).races.last.should eql(external_codes(:race_white))
    end
  end

end

describe Entity, "with multiple telephones" do
  fixtures :entities, :entities_locations, :locations, :external_codes

  it "should have telephone entities locations" do
    entities(:Silvers).telephone_entities_location.should_not be_nil
  end

  it "should be able to return all telephone entities locations" do
    entities(:Silvers).telephone_entities_locations.length.should == 2
  end

end

