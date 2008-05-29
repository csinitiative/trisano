require File.dirname(__FILE__) + '/../spec_helper'

describe FormElement do
  before(:each) do
    @form_element = FormElement.new
  end

  it "should be valid" do
    @form_element.should be_valid
  end
  
  it "should count children by type" do
    @form_base_element = FormBaseElement.create(:tree_id => 1, :form_id => 1, :name => "base")
    @view_element = ViewElement.create(:tree_id => 1, :form_id => 1, :name => "view")
    @view_element2 = ViewElement.create(:tree_id => 1, :form_id => 1, :name => "view 2")
    @section_element = SectionElement.create(:tree_id => 1, :form_id => 1, :name => "section")
    
    @form_base_element.add_child(@view_element)
    @form_base_element.add_child(@view_element2)
    @form_base_element.add_child(@section_element)
    
    @form_base_element.children_count_by_type("ViewElement").should == 2
    @form_base_element.children_count_by_type("SectionElement").should == 1
    
  end
    
  it "should return children by type" do
    @form_base_element = FormBaseElement.create(:tree_id => 1, :form_id => 1, :name => "base")
    @view_element = ViewElement.create(:tree_id => 1, :form_id => 1, :name => "view")
    @view_element2 = ViewElement.create(:tree_id => 1, :form_id => 1, :name => "view 2")
    @section_element = SectionElement.create(:tree_id => 1, :form_id => 1, :name => "section")
    
    @form_base_element.add_child(@view_element)
    @form_base_element.add_child(@view_element2)
    @form_base_element.add_child(@section_element)
    
    view_children = @form_base_element.children_by_type("ViewElement")
    view_children.size.should == 2
    view_children[0].is_a?(ViewElement).should be_true
    
  end
  
end

describe "Quesiton FormElement" do
  before(:each) do
    @form_element = QuestionElement.create
  end

  it "should destroy associated question on destroying with dependencies" do
    question = Question.create({:question_text => "Que?", :data_type => "single_line_text"})
    form_element_id = @form_element.id
    question_id = question.id
    @form_element.question = question
    
    FormElement.exists?(form_element_id).should be_true
    Question.exists?(question_id).should be_true
    
    @form_element.destroy_with_dependencies
    
    FormElement.exists?(form_element_id).should be_false
    Question.exists?(question_id).should be_false
    
  end
  
end
