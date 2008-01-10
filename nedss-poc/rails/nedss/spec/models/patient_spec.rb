require File.dirname(__FILE__) + '/../spec_helper'

describe Patient do
  before(:each) do
    @patient = Patient.new
  end

  it "should be valid" do
    @patient.should be_valid
  end
end
