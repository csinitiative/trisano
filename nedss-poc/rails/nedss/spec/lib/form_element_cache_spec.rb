require File.dirname(__FILE__) + '/../spec_helper'

describe FormElementCache do
  
  before(:each) do
    
    tree_id = Form.find_by_sql("SELECT nextval('tree_id_generator')").first.nextval.to_i
    
    @form_base_element = FormBaseElement.create(:tree_id => tree_id, :form_id => 1, :name => "base")
    @view_element = ViewElement.create(:tree_id => tree_id, :form_id => 1, :name => "view")
    @view_element_2 = ViewElement.create(:tree_id => tree_id, :form_id => 1, :name => "view 2")
    @section_element = SectionElement.create(:tree_id => tree_id, :form_id => 1, :name => "section")
    
    @form_base_element.add_child(@view_element)
    @form_base_element.add_child(@view_element_2)
    @form_base_element.add_child(@section_element)
    
    @question_element_1 = QuestionElement.create(:tree_id => tree_id, :form_id => 1)
    @section_element.add_child(@question_element_1)
    
    @follow_up = FollowUpElement.create(:tree_id => tree_id, :form_id => 1, :condition => "Yes", :core_path => "event[something]")
    @question_element_1.add_child(@follow_up)
    
    @follow_up_q1 = QuestionElement.create(:tree_id => tree_id, :form_id => 1)
    @follow_up.add_child(@follow_up_q1)
    
    @question_element_2 = QuestionElement.create(:tree_id => tree_id, :form_id => 1)
    @section_element.add_child(@question_element_2)
    
    @question_element_3 = QuestionElement.create(:tree_id => tree_id, :form_id => 1)
    @section_element.add_child(@question_element_3)
    
    @form_element_cache = FormElementCache.new(@form_base_element)
    
  end
          
  it "should handle bogus constructor args" do
    lambda {FormElementCache.new(String.new)}.should raise_error(ArgumentError, "FormElementCache initialize only handles FormElements")
  end

  it "should count children of an element" do
    @form_element_cache.children_count(@form_base_element).should == 3
  end
  
  it "should return children of an element" do
    children = @form_element_cache.children(@form_base_element)
    children.is_a?(Array).should be_true
    children.size.should == 3
    children[0].is_a?(ViewElement).should be_true
  end
  
  it "should return all children of an element" do
    @form_element_cache = FormElementCache.new(@form_base_element)
    children = @form_element_cache.all_children(@form_base_element)
    children.is_a?(Array).should be_true
    children.size.should == 8
  end
  
  it "should return all children by filter" do
    children = @form_element_cache.all_follow_ups_by_core_path("event[something]", @form_base_element)
    children.is_a?(Array).should be_true
    children.size.should == 1
    children[0].is_a?(FollowUpElement).should be_true
  end
  
  it "should count children by type" do
    @form_element_cache.children_count_by_type("ViewElement", @form_base_element).should == 2
    @form_element_cache.children_count_by_type("SectionElement", @form_base_element).should == 1
  end
    
  it "should return children by type" do
    view_children = @form_element_cache.children_by_type("ViewElement", @form_base_element)
    view_children.size.should == 2
    view_children[0].is_a?(ViewElement).should be_true
  end

end