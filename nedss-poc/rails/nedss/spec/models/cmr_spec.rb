require File.dirname(__FILE__) + '/../spec_helper'

describe Cmr do
  before(:each) do
    @cmr = Cmr.new
  end

  it "should be valid" do
    @cmr.should be_valid
  end
end

describe Cmr, "with fixtures loaded" do
  fixtures :cmrs, :patients

  it "should have a non-empty collection of cmrs" do
    Cmr.find(:all).should_not be_empty
  end

  it "should have one record" do
    Cmr.should have(1).record
  end

  it "should find an existing CMR" do
    cmr = Cmr.find(cmrs(:basic_cmr).id)
    cmr.should eql(cmrs(:basic_cmr))
  end

  it "should have a patient named Jenkins " do
    cmrs(:basic_cmr).patient.last_name.should == patients(:sammy_jenkins).last_name
  end

  # TODO: Test disease relationship
  # TODO: Test accession number when I find out what Ed meant by that
end
