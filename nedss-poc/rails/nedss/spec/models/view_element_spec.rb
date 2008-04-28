require File.dirname(__FILE__) + '/../spec_helper'

describe ViewElement do
  before(:each) do
    @view_element = ViewElement.new
  end

  it "should be valid" do
    @view_element.should be_valid
  end
end
