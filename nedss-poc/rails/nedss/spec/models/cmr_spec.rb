require File.dirname(__FILE__) + '/../spec_helper'

describe Cmr, "with a last name" do
  before(:each) do
#    @cmr = Cmr.new(:last_name => "Public", :date_of_birth => "November 11, 1987")
    @cmr = Cmr.new(:last_name => "Public")
  end

  it "should be valid" do
    @cmr.should be_valid
  end

  it "should have no errors after save" do
    @cmr.save.should be_true
    @cmr.errors.should be_empty
  end 
end


