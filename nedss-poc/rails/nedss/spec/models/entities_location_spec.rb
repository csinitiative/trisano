require File.dirname(__FILE__) + '/../spec_helper'

describe "Global Context" do
  fixtures :codes

  describe EntitiesLocation do
    before(:each) do
      @entity_location = EntitiesLocation.new
    end

    it "should be valid" do
      @entity_location.should be_valid
    end

    describe "with fixtures loaded" do
      fixtures :entities_locations

      it "should have three records" do
        EntitiesLocation.should have(3).records
      end

      it "A Phil Silvers record should point to Phil Silvers" do
        entities_locations(:silvers_joined_to_home_address).entity_id.should eql(2)
      end

      it "A home join location should point to home location" do
        entities_locations(:silvers_joined_to_home_address).location_id.should eql(1)
      end
    end
  end
end
