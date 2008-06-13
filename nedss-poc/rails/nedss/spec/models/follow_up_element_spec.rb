require File.dirname(__FILE__) + '/../spec_helper'

describe FollowUpElement do
  before(:each) do
    @follow_up_element = FollowUpElement.new
    @follow_up_element.form_id = 1
    @follow_up_element.condition = "Yes"
  end

  it "should be valid" do
    @follow_up_element.should be_valid
  end
  
  describe "when created with 'save and add to form'" do
    
    it "should be a child of the question provided" do
      question_element = QuestionElement.create({:form_id => 1, :tree_id => 1})
      @follow_up_element.parent_element_id = question_element.id
      @follow_up_element.save_and_add_to_form
      @follow_up_element.parent_id.should_not be_nil
      question_element = FormElement.find(question_element.id)
      question_element.children[0].id.should == @follow_up_element.id 
    end
    
    it "should be receive a tree id" do
      question_element = QuestionElement.create({:form_id => 1, :tree_id => 1})
      @follow_up_element.parent_element_id = question_element.id
      @follow_up_element.save_and_add_to_form
      @follow_up_element.tree_id.should_not be_nil
      @follow_up_element.tree_id.should eql(question_element.tree_id)
    end
    
  end
  
  describe "when processing conditional logic for core follow ups'" do
    
    fixtures :codes, :participations, :places, :diseases, :disease_events, :forms, :form_elements, :questions
    
    before(:each) do
      
      # Debt: Building and saving an event because the fixture-driven event is not currently valid (rake fails loading event fixtures)
      @event = Event.new
      @event.disease_events << disease_events(:marks_chicken_pox)
      @event.jurisdiction = participations(:marks_jurisdiction)
      @event.save(false)
      
      @no_follow_up_answer = Answer.create(:event_id => @event.id, :question_id => questions(:second_tab_core_follow_up_q).id, :text_answer => "YES!")
      
    end
    
    it "should return follow-up element with a 'show' attribute for matching core path with matching condition" do
      params = {}
      
      params[:event_id] = @event.id
      params[:core_path] = form_elements(:second_tab_core_follow_up).core_path
      params[:response] = form_elements(:second_tab_core_follow_up).condition
      
      follow_ups = FollowUpElement.process_core_condition(params)
      
      # Debt: The magic container for core follow ups needs to go probably
      follow_ups[0][0].should eql("show")
      follow_ups[0][1].is_a?(FollowUpElement).should be_true
      
    end
    
    it "should return follow-up element with a 'hide' attribute for matching core path without a matching condition" do
      params = {}
      
      params[:event_id] = @event.id
      params[:core_path] = form_elements(:second_tab_core_follow_up).core_path
      params[:response] = "no match"
      
      follow_ups = FollowUpElement.process_core_condition(params)
      
      # Debt: The magic container for core follow ups needs to go probably
      follow_ups[0][0].should eql("hide")
      follow_ups[0][1].is_a?(FollowUpElement).should be_true
    end
    
    it "should return no follow-up elements without a matching core path or matching condition" do
      params = {}
      
      params[:event_id] = @event.id
      params[:core_path] = "no match"
      params[:response] = "no match"
      
      follow_ups = FollowUpElement.process_core_condition(params)
      
      follow_ups.empty?.should be_true
    end
    
    it "should delete answers to questions that no longer apply" do
      params = {}
      
      params[:event_id] = @event.id
      params[:core_path] = form_elements(:second_tab_core_follow_up).core_path
      params[:response] = "no match"
      
      follow_ups = FollowUpElement.process_core_condition(params)
      
      begin
        deleted_existing_answer = Answer.find(@no_follow_up_answer.id)
      rescue
        # No-op
      ensure
        deleted_existing_answer.should be_nil
      end
      
    end
    
    it "should not delete answers if conditions apply" do
      params = {}
      
      params[:event_id] = @event.id
      params[:core_path] = form_elements(:second_tab_core_follow_up).core_path
      params[:response] = form_elements(:second_tab_core_follow_up).condition
      
      follow_ups = FollowUpElement.process_core_condition(params)
      
      Answer.find(@no_follow_up_answer.id).should_not be_nil
    end
    
  end
  
end
