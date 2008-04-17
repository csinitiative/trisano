require File.dirname(__FILE__) + '/../spec_helper'

describe Responses do
  before(:each) do
    @responses = Responses.new
  end

  it "should be valid" do
    @responses.should be_valid
  end
end
