require File.dirname(__FILE__) + '/../spec_helper'

describe ViewElement do
  before(:each) do
    @view_element = ViewElement.new
    @view_element.name = "Test Tab"
    @view_element.form_id = 1
  end

  it "should be valid" do
    @view_element.should be_valid
  end
  
  describe "when created with 'save and add to form'" do
    
    it "should be a child of the form's base" do
      form = Form.new
      form.save_and_initialize_form_elements
      @view_element.parent_element_id = form.investigator_view_elements_container.id
      @view_element.save_and_add_to_form
      @view_element.parent_id.should_not be_nil
      form.investigator_view_elements_container.children[1].id.should == @view_element.id
    end
    
    it "should be receive a tree id" do
      form = Form.new
      form.save_and_initialize_form_elements
      @view_element.parent_element_id = form.investigator_view_elements_container.id
      @view_element.save_and_add_to_form
      @view_element.tree_id.should_not be_nil
      @view_element.tree_id.should eql(form.form_base_element.tree_id)
    end
    
  end
  
end
