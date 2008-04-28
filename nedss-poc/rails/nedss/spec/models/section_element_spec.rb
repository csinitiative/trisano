require File.dirname(__FILE__) + '/../spec_helper'

describe SectionElement do
  before(:each) do
    @section_element = SectionElement.new
  end

  it "should be valid" do
    @section_element.should be_valid
  end
end
