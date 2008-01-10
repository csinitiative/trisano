require File.dirname(__FILE__) + '/../spec_helper'

describe Ethnicity do
  before(:each) do
    @ethnicity = Ethnicity.new
  end

  it "should be valid" do
    @ethnicity.should be_valid
  end
end
