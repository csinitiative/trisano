require File.dirname(__FILE__) + '/../spec_helper'

describe BeforeCoreFieldElement do
  before(:each) do
    @before_core_field_element = BeforeCoreFieldElement.new
  end

  it "should be valid" do
    @before_core_field_element.should be_valid
  end
  
    it "should return nil for save_and_add_to_form" do
    @before_core_field_element.save_and_add_to_form.should be_nil
  end
  
end
