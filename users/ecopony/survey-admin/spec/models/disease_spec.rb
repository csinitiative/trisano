require File.dirname(__FILE__) + '/../spec_helper'

describe Disease do
  before(:each) do
    @disease = Disease.new
    @disease.name = "Bad Back"
  end

  it "should be valid" do
    @disease.should be_valid
  end
end
