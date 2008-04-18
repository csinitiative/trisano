require File.dirname(__FILE__) + '/../spec_helper'

describe Response do
  before(:each) do
    @response = Response.new
  end

  it "should be valid" do
    @response.should be_valid
  end
end
