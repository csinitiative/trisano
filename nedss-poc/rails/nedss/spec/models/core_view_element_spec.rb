require File.dirname(__FILE__) + '/../spec_helper'

describe CoreViewElement do
  before(:each) do
    @core_view_element = CoreViewElement.new
    @core_view_element.form_id = 1
    @core_view_element.name = "demographics"
  end

  it "should be valid" do
    @core_view_element.should be_valid
  end
  
  describe "when created with 'save and add to form'" do
    
    it "should be a child of the form's base" do
      form = Form.new
      form.save_and_initialize_form_elements
      @core_view_element.form_id = form.id
      @core_view_element.save_and_add_to_form
      @core_view_element.parent_id.should_not be_nil
      form.form_base_element.children[1].id.should == @core_view_element.id
    end
    
  end

end