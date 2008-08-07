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
    @form_element = QuestionElement.create(:tree_id => 1, :form_id => 1)
    @question = Question.create({:question_text => "Que?", :data_type => "single_line_text"})
    @form_element.question = @question
  end

  it "should destroy associated question on destroying with dependencies" do
    
    form_element_id = @form_element.id
    question_id = @question.id
    
    FormElement.exists?(form_element_id).should be_true
    Question.exists?(question_id).should be_true
    
    @form_element.destroy_with_dependencies
    
    FormElement.exists?(form_element_id).should be_false
    Question.exists?(question_id).should be_false
    
  end
end

describe "Quesiton FormElement when added to library" do
  
  before(:each) do
    @form_element = QuestionElement.create(:tree_id => 1, :form_id => 1)
    @question = Question.create({:question_text => "Que?", :data_type => "single_line_text", :short_name => "que_q" })
    @form_element.question = @question
    
  end
  
  it "the copy should have a correct ids and type" do
    @library_question = @form_element.add_to_library(nil)
    @library_question.id.should_not be_nil
    @library_question.form_id.should be_nil
    @library_question.template_id.should be_nil
    @library_question.parent_id.should be_nil
    @library_question.type.should eql("QuestionElement")
    @library_question.tree_id.should_not be_nil
    @library_question.tree_id.should_not eql(@form_element.tree_id)
  end
    
  it "the copy should be a template" do
    @library_question = @form_element.add_to_library(nil)
    @library_question.is_template.should be_true
  end
    
  it "the question copy should be a clone of the question it was created from" do
    @library_question = @form_element.add_to_library(nil)
    @library_question.question.should_not be_nil
    @library_question.question.question_text.should eql(@question.question_text)
    @library_question.question.data_type.should eql(@question.data_type)
    @library_question.question.short_name.should eql(@question.short_name)
  end
    
  it "the copy should have follow up questions" do
    follow_up_container = FollowUpElement.create({:tree_id => 1, :form_id => 1,:name => "Follow up", :condition => "Yes"})
    follow_up_question_element = QuestionElement.create(:tree_id => 1, :form_id => 1)
    follow_up_question = Question.create({:question_text => "Did you do it?", :data_type => "single_line_text"})
    follow_up_question_element.question = follow_up_question
    follow_up_container.add_child(follow_up_question_element)
    @form_element.add_child(follow_up_container)
    
    @library_question = @form_element.add_to_library(nil)
    follow_up_copy = @library_question.children[0]
    follow_up_copy.name.should eql(follow_up_container.name)
    follow_up_copy.condition.should eql(follow_up_container.condition)
    
    follow_up_copy_quesiton_element = follow_up_copy.children[0]
    follow_up_copy_quesiton_element.should_not be_nil
    follow_up_copy_quesiton_element.question.should_not be_nil
    follow_up_copy_quesiton_element.question.question_text.should eql(follow_up_question.question_text)
    follow_up_copy_quesiton_element.question.data_type.should eql(follow_up_question.data_type)
    
  end
   
end
