require File.dirname(__FILE__) + '/../spec_helper'

describe GroupElement do
  before(:each) do
    @group_element = GroupElement.new
  end

  it "should be valid" do
    @group_element.should be_valid
  end
end
