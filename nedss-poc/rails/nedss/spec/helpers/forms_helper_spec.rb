require File.dirname(__FILE__) + '/../spec_helper'

describe FormsHelper do
  
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
