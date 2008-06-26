require File.dirname(__FILE__) + '/../spec_helper'

describe CoreViewElementContainer do
  before(:each) do
    @core_view_element_container = CoreViewElementContainer.new
  end

  it "should be valid" do
    @core_view_element_container.should be_valid
  end
  
  it "should return nil for save_and_add_to_form" do
    @core_view_element_container.save_and_add_to_form.should be_nil
  end
  
end
