require File.dirname(__FILE__) + '/../spec_helper'

describe FormsHelper do
  
  describe "core field element rendering" do
    
    it "should contain the core field name" do
      form = Form.new
      form.save_and_initialize_form_elements
      core_field_element = CoreFieldElement.new(:core_path => Event.exposed_attributes.keys[0])
      core_field_element.parent_element_id = form.core_field_elements_container.id
      core_field_element.save_and_add_to_form
      render_core_field(core_field_element).should include(Event.exposed_attributes[Event.exposed_attributes.keys[0]][:name])
    end
  end
  
  describe "core follow up rendering" do
    
    it "should contain the core data element name" do
      core_attribute_key = Event.exposed_attributes.keys.first
      core_attribute_name = Event.exposed_attributes[core_attribute_key][:name]
      
      question = QuestionElement.create
      follow_up = FollowUpElement.create({:condition => "yes", :core_path => core_attribute_key})
      question.add_child(follow_up)
      
      render_follow_up(follow_up).should include("Core data element")
      render_follow_up(follow_up).should include(core_attribute_name)
    end
    
  end
  
  describe "standard follow up rendering" do
    
    it "should not contain the core data information" do
      question = QuestionElement.create
      follow_up = FollowUpElement.create({:condition => "yes"})
      question.add_child(follow_up)
      render_follow_up(follow_up).should_not include("Core data element")
    end
  end
  
end
