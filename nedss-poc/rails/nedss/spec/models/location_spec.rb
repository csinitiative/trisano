require File.dirname(__FILE__) + '/../spec_helper'

describe Location do
  before(:each) do
    @location = Location.new
  end

  it "should be valid" do
    @location.should be_valid
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
end

describe Location, "with fixtures loaded" do
  fixtures :locations, :addresses

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
end



