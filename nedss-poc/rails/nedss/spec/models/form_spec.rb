require File.dirname(__FILE__) + '/../spec_helper'

describe Form do
  before(:each) do
    @form = Form.new
  end

  it "should be valid" do
    @form.should be_valid
  end
end
