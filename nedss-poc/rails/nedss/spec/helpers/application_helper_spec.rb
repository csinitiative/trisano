require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  
  it "should determine replacement elements for a investigator view child" do
    form_base_element = FormBaseElement.create(:tree_id => "1")
    investigator_view_element_container = InvestigatorViewElementContainer.create(:tree_id => "1")
    question_element = QuestionElement.create(:tree_id => "1")
    
    form_base_element.add_child(investigator_view_element_container)
    investigator_view_element_container.add_child(question_element)
    
    replace_element, replace_partial = replacement_elements(question_element)
    
    replace_element.should eql("root-element-list")
    replace_partial.should eql("forms/elements")
  end
  
  it "should determine replacement elements for a core view child" do
    form_base_element = FormBaseElement.create(:tree_id => "1")
    core_view_element_container = CoreViewElementContainer.create(:tree_id => "1")
    question_element = QuestionElement.create(:tree_id => "1")
    
    form_base_element.add_child(core_view_element_container)
    core_view_element_container.add_child(question_element)
    
    replace_element, replace_partial = replacement_elements(question_element)
    
    replace_element.should eql("core-element-list")
    replace_partial.should eql("forms/core_elements")
  end
  
  it "should determine replacement elements for a core field child" do
    form_base_element = FormBaseElement.create(:tree_id => "1")
    core_field_element_container = CoreFieldElementContainer.create(:tree_id => "1")
    question_element = QuestionElement.create(:tree_id => "1")
    
    form_base_element.add_child(core_field_element_container)
    core_field_element_container.add_child(question_element)
    
    replace_element, replace_partial = replacement_elements(question_element)
    
    replace_element.should eql("core-field-element-list")
    replace_partial.should eql("forms/core_field_elements")
  end
  
end
