require File.dirname(__FILE__) + '/../spec_helper'

describe "Global Context" do
  fixtures :codes

  describe Location do
    before(:each) do
      @location = Location.new
    end

    it "should not be valid with a phone or address component" do
      @location.should_not be_valid
    end

    describe "with associated address" do
      before(:each) do
        @address = Address.new
      end

      it "should be invalid to have an empty address" do
        @location.addresses << @address
        @location.should_not be_valid
      end

      it "should be valid to have a filled in address" do
        @address.street_name = "Spruce St."
        @location.addresses << @address
        @location.should be_valid
      end
    end

    describe "with an associated telephone number" do
      # Someday
    end
  end


  describe Location, "with fixtures loaded" do
    fixtures :locations, :addresses, :entities, :entities_locations

    it "Phil Silvers should have two work addresses" do
      locations(:silvers_work_address).should have(2).addresses
    end

    it "Phil Silvers should have one current work address" do
      locations(:silvers_work_address).current_address.street_name.should eql("Pine Rd.")
    end

    it "Phil Silvers should have one home addresses" do
      locations(:silvers_home_address).should have(1).addresses
    end

    it "Phil Silvers should have one current home address" do
      locations(:silvers_home_address).current_address.street_name.should eql("Birch St.")
    end

    describe "using nested attributes" do
      describe "with new" do
        it "should save without errors" do
          @location = Location.new( :entities_location => { :entity_id => 1, :primary_yn_id => 1402, :entity_location_type_id => 1302 },
                                  :address => { :street_number => '99', :street_name => '9th Ave.' },
                                  :telephone => { :area_code => '212', :phone_number => '555-1212' } )
          @location.save.should be_true
        end
      end

      describe "with update_attributes" do
        it "should save without errors" do
          entity = Entity.find(2)
          @location = entity.locations.first
          @location.update_attributes( :entities_location => { :entity_id => entity.id, :primary_yn_id => 1402, :entity_location_type_id => 1302 },
                                  :address => { :street_number => '99', :street_name => '9th Ave.' },
                                  :telephone => { :area_code => '212', :phone_number => '5551212' } ).should be_true
        end
      end
    end
  end
end
