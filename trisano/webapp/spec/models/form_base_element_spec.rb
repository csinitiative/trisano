require File.dirname(__FILE__) + '/../spec_helper'

describe FormBaseElement do
  before(:each) do
    @form_base_element = FormBaseElement.new
  end

  it "should be valid" do
    @form_base_element.should be_valid
  end
end
