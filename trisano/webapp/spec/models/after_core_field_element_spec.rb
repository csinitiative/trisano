require File.dirname(__FILE__) + '/../spec_helper'

describe AfterCoreFieldElement do
  before(:each) do
    @after_core_field_element = AfterCoreFieldElement.new
  end

  it "should be valid" do
    @after_core_field_element.should be_valid
  end
  
  it "should return nil for save_and_add_to_form" do
    @after_core_field_element.save_and_add_to_form.should be_nil
  end
end
