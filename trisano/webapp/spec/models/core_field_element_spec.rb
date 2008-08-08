require File.dirname(__FILE__) + '/../spec_helper'

describe CoreFieldElement do
  before(:each) do
    @core_field_element = CoreFieldElement.new
    @core_field_element.core_path = MorbidityEvent.exposed_attributes.keys[0]
  end

  it "should be valid" do
    @core_field_element.name = "name"
    @core_field_element.should be_valid
  end

  describe "when determining available core fields" do
    
    it "should return nil if no parent_element_id is set on the core field element" do
      @core_field_element.available_core_fields.should be_nil
    end
    
    it "should return all core field names when none are in use" do
      form = Form.new
      form.save_and_initialize_form_elements
      @core_field_element.parent_element_id = form.form_base_element.id
      available_core_fields = @core_field_element.available_core_fields
      available_core_fields.size.should == 25
      available_core_fields.flatten.include?(MorbidityEvent.exposed_attributes.keys[0]).should be_true
    end
    
    it "should return only available core view names when some are in use" do
      form = Form.new
      form.save_and_initialize_form_elements
      base_element_id = form.form_base_element.id
     
      patent_last_name_field_config = CoreFieldElement.new(
        :parent_element_id => base_element_id, 
        :core_path => MorbidityEvent.exposed_attributes.keys[0]
      )
      patent_last_name_field_config.save_and_add_to_form
       
      @core_field_element.parent_element_id = base_element_id
      available_core_fields = @core_field_element.available_core_fields
      available_core_fields.size.should == 24
      available_core_fields.flatten.include?(MorbidityEvent.exposed_attributes.keys[0]).should be_false
    end
    
  end
  
  describe "when created with 'save and add to form'" do
    
    it "should be a child of the form's base" do
      form = Form.new
      form.save_and_initialize_form_elements
      @core_field_element.parent_element_id = form.core_field_elements_container.id
      @core_field_element.save_and_add_to_form
      @core_field_element.parent_id.should_not be_nil
      form.core_field_elements_container.children[0].id.should == @core_field_element.id
    end
    
    it "should have a name" do
      form = Form.new
      form.save_and_initialize_form_elements
      @core_field_element.parent_element_id = form.core_field_elements_container.id
      @core_field_element.save_and_add_to_form
      @core_field_element.reload
      @core_field_element.name.should eql(MorbidityEvent.exposed_attributes[MorbidityEvent.exposed_attributes.keys[0]][:name])
    end
    
    it "should override any name provided with the one in the exposed attributes" do
      form = Form.new
      form.save_and_initialize_form_elements
      @core_field_element.parent_element_id = form.core_field_elements_container.id
      @core_field_element.name = "name assigned"
      @core_field_element.save_and_add_to_form
      @core_field_element.reload
      @core_field_element.name.should eql(MorbidityEvent.exposed_attributes[MorbidityEvent.exposed_attributes.keys[0]][:name])
    end
    
    it "should receive a tree id" do
      form = Form.new
      form.save_and_initialize_form_elements
      @core_field_element.parent_element_id = form.core_field_elements_container.id
      @core_field_element.save_and_add_to_form
      @core_field_element.tree_id.should_not be_nil
      @core_field_element.tree_id.should eql(form.form_base_element.tree_id)
    end
    
    it "should bootstrap the before and after core field elements" do
      form = Form.new
      form.save_and_initialize_form_elements
      @core_field_element.parent_element_id = form.core_field_elements_container.id
      @core_field_element.save_and_add_to_form
      @core_field_element.children.size.should eql(2)
      @core_field_element.children[0].is_a?(BeforeCoreFieldElement).should be_true
      @core_field_element.children[1].is_a?(AfterCoreFieldElement).should be_true
    end
    
  end
  
end
