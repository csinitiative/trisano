require File.dirname(__FILE__) + '/../spec_helper'

describe ValueElement do
  before(:each) do
    @value_element = ValueElement.new
  end

  it "should be valid" do
    @value_element.should be_valid
  end
 
end
