require File.dirname(__FILE__) + '/../spec_helper'

describe FormStatus do
  before(:each) do
    @form_status = FormStatus.new
  end

  it "should be valid" do
    @form_status.should be_valid
  end
end
