require File.dirname(__FILE__) + '/../spec_helper'

describe InvestigatorViewElementContainer do
  before(:each) do
    @investigator_view_element_container = InvestigatorViewElementContainer.new
  end

  it "should be valid" do
    @investigator_view_element_container.should be_valid
  end
  
    it "should return nil for save_and_add_to_form" do
    @investigator_view_element_container.save_and_add_to_form.should be_nil
  end
  
end
