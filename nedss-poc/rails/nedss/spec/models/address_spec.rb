require File.dirname(__FILE__) + '/../spec_helper'

describe Address do
  before(:each) do
    @address = Address.new
  end

  it "should be invalid without at least one non-blank attrbute" do
    @address.should_not be_valid
  end

  it "should be valid with one non-blank attrbute" do
    @address.street_number = "123"
    @address.should be_valid
  end

  it "should be valid with one or more non-blank attrbutes" do
    @address.street_number = "123"
    @address.street_name = "Main St."
    @address.should be_valid
  end
end
