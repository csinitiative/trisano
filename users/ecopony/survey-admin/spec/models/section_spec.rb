require File.dirname(__FILE__) + '/../spec_helper'

describe Section do
  before(:each) do
    @section = Section.new
    @section.name = "Tummy Ache Demographics"
  end

  it "should be valid" do
    @section.should be_valid
  end
end
