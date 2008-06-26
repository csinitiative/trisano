require File.dirname(__FILE__) + '/../spec_helper'

describe SectionElement do
  before(:each) do
    @section_element = SectionElement.new
    @section_element.name="Section 1"
  end

  it "should be valid" do
    @section_element.should be_valid
  end
  
  describe "when created with 'save and add to form'" do
    
    it "should be a child of the form's investigator element container" do
      form = Form.new
      form.save_and_initialize_form_elements
      
      @section_element.parent_element_id = form.investigator_view_elements_container.id
      @section_element.save_and_add_to_form
      @section_element.parent_id.should_not be_nil
      form.investigator_view_elements_container.children[1].id.should == @section_element.id
    end
    
    it "should be receive a tree id" do
      form = Form.new
      form.save_and_initialize_form_elements
      
      @section_element.parent_element_id = form.investigator_view_elements_container.id
      @section_element.save_and_add_to_form
      
      @section_element.tree_id.should_not be_nil
      @section_element.tree_id.should eql(form.form_base_element.tree_id)
    end
    
  end
  
end