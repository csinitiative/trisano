require File.dirname(__FILE__) + '/../spec_helper'

describe Form do
  before(:each) do
    @form = Form.new
  end

  it "should be valid" do
    @form.should be_valid
  end
  
  describe "when created with save_and_initialize_form_elements" do
    
    fixtures :forms, :form_elements, :questions
    
    it "should bootstrap the form element hierarchy" do
      @form.save_and_initialize_form_elements
      form_base_element = @form.form_base_element
      form_base_element.should_not be_nil
      default_view_element = form_base_element.children[0]
      default_view_element.should_not be_nil
      default_view_element.name.should == "Default View"
    end
    
    it "should have a template's properties" do
      @form.save_and_initialize_form_elements
      @form.is_template.should be_true
      @form.template_id.should be_nil
      @form.version.should be_nil
      @form.status.should eql("Not Published")
    end
    
  end
  
  describe "when trying to call publish on a published instance" do
    
    fixtures :forms, :form_elements, :questions
    
    it "should fail" do
      form_to_publish = Form.find(1)
      error_message = ""
      
      begin
        published_form = form_to_publish.publish!
        published_form.publish!
      rescue RuntimeError => error
        error_message = error.message
      end
      
      error_message.should eql("Cannot publish an already published version")
      
    end
    
  end
  
  describe "when first published" do
    
    fixtures :forms, :form_elements, :questions
    
    it "should give itself published status" do
      form_to_publish = Form.find(1)
      published_form = form_to_publish.publish!
      form_to_publish.status.should eql("Published")
    end
    
    it "should give the base form element a tree id" do
      pending
    end
    
    it "should make a copy of itself and give the copy published version properties" do
      form_to_publish = Form.find(1)
      published_form = form_to_publish.publish!
      published_form.should_not be_nil
      published_form.version.should eql(1)
      published_form.is_template.should be_false
      published_form.template_id.should eql(form_to_publish.id)
      published_form.status.should eql("Live")
    end
    
    it "should make a copy of the entire form element tree" do
      form_to_publish = Form.find(1)
      published_form = form_to_publish.publish!
      
      published_form.form_base_element.should_not be_nil
      published_form_base = published_form.form_base_element
      published_form_base.children_count.should eql(2)
      
      default_view = published_form_base.children[0]
      default_view.form_id.should eql(published_form.id)
      default_view.children_count.should eql(3)
      
      demo_section = default_view.children[0]
      demo_section.class.name.should eql("SectionElement")
      demo_section.form_id.should eql(published_form.id)
      demo_section.name.should eql(form_elements(:demographic_section).name)
      
      demo_group = demo_section.children[0]
      demo_group.class.name.should eql("GroupElement")
      demo_group.form_id.should eql(published_form.id)
      demo_group.name.should eql(form_elements(:demographic_group).name)
      
      demo_q1 = demo_group.children[0]
      demo_q1.class.name.should eql("QuestionElement")
      demo_q1.form_id.should eql(published_form.id)
      demo_q1.name.should be_nil
      
      demo_q2 = demo_group.children[1]
      demo_q2.class.name.should eql("QuestionElement")
      demo_q2.form_id.should eql(published_form.id)
      demo_q2.name.should be_nil
      
      demo_q3 = demo_group.children[2]
      demo_q3.class.name.should eql("QuestionElement")
      demo_q3.form_id.should eql(published_form.id)
      demo_q3.name.should be_nil
      
      lab_section = default_view.children[1]
      lab_section.class.name.should eql("SectionElement")
      lab_section.form_id.should eql(published_form.id)
      lab_section.name.should eql(form_elements(:lab_section).name)
      
      lab_q1 = lab_section.children[0]
      lab_q1.class.name.should eql("QuestionElement")
      lab_q1.form_id.should eql(published_form.id)
      lab_q1.name.should be_nil
      
      lab_q2 = lab_section.children[1]
      lab_q2.class.name.should eql("QuestionElement")
      lab_q2.form_id.should eql(published_form.id)
      lab_q2.name.should be_nil
      
      lab_q3 = lab_section.children[2]
      lab_q3.class.name.should eql("QuestionElement")
      lab_q3.form_id.should eql(published_form.id)
      lab_q3.name.should be_nil
      
      food_section = default_view.children[2]
      food_section.class.name.should eql("SectionElement")
      food_section.form_id.should eql(published_form.id)
      food_section.name.should eql(form_elements(:food_section).name)
      
      food_group = food_section.children[0]
      food_group.class.name.should eql("GroupElement")
      food_group.form_id.should eql(published_form.id)
      food_group.name.should eql(form_elements(:standard_food_group).name)
      
      food_q1 = food_group.children[0]
      food_q1.class.name.should eql("QuestionElement")
      food_q1.form_id.should eql(published_form.id)
      food_q1.name.should be_nil
      
      food_q2 = food_group.children[1]
      food_q2.class.name.should eql("QuestionElement")
      food_q2.form_id.should eql(published_form.id)
      food_q2.name.should be_nil
      
      food_q3 = food_section.children[1]
      food_q3.class.name.should eql("QuestionElement")
      food_q3.form_id.should eql(published_form.id)
      food_q3.name.should be_nil
      
      second_tab = published_form_base.children[1]
      second_tab.form_id.should eql(published_form.id)
      second_tab.children_count.should eql(1)
      
      second_tab_q = second_tab.children[0]
      second_tab_q.class.name.should eql("QuestionElement")
      second_tab_q.form_id.should eql(published_form.id)
      second_tab_q.name.should be_nil
      second_tab_q.question.should_not be_nil
      
      second_tab_follow_up = second_tab_q.children[0]
      second_tab_follow_up.class.name.should eql("FollowUpElement")
      second_tab_follow_up.form_id.should eql(published_form.id)
      second_tab_follow_up.condition.should eql(form_elements(:second_tab_follow_up_container).condition)
      
      second_tab_follow_up_q = second_tab_follow_up.children[0]
      second_tab_follow_up_q.class.name.should eql("QuestionElement")
      second_tab_follow_up_q.form_id.should eql(published_form.id)
      second_tab_follow_up_q.name.should be_nil
      second_tab_follow_up_q.question.should_not be_nil
      
    end
    
    it "should make a copy of the question instances" do
      form_to_publish = Form.find(1)
      published_form = form_to_publish.publish!
      
      default_view = published_form.form_base_element.children[0]
      demo_section = default_view.children[0]
      demo_group = demo_section.children[0]
      
      demo_q1 = demo_group.children[0]
      
      demo_q1.question.should_not be_nil
      demo_q1.question.question_text.should eql(questions(:demo_q1).question_text)
    end
    
    it "should not make a copy of the inactive questions" do
      form_to_publish = Form.find(1)
      
      default_view = form_to_publish.form_base_element.children[0]
      demo_section = default_view.children[0]
      demo_group = demo_section.children[0]
      demo_q1 = demo_group.children[0]
      
      demo_q1.question.question_text.should eql(questions(:demo_q1).question_text)
      demo_q1.is_active = false
      demo_q1.save
      
      published_form = form_to_publish.publish!
      
      default_view = published_form.form_base_element.children[0]
      demo_section = default_view.children[0]
      demo_group = demo_section.children[0]
      demo_q1 = demo_group.children[0]
      
      demo_q1.question.should_not be_nil
      demo_q1.question.question_text.should_not eql(questions(:demo_q1).question_text)
      demo_q1.question.question_text.should eql(questions(:demo_q2).question_text)
    end
    
  end
  
  describe "when published a second time" do
    
    fixtures :forms, :form_elements, :questions
    
    it "should give the second version live status and first version archived status" do
      form_to_publish = Form.find(1)
      first_version = form_to_publish.publish!
      first_version.status.should eql("Live")
      second_version = form_to_publish.publish!
      second_version.status.should eql("Live")
      first_version.reload
      first_version.status.should eql("Archived")
    end
    
  end
  
  describe "the get_investigation_forms class method" do
    fixtures :forms

    it "should return four forms" do
      forms = Form.get_published_investigation_forms(1, 1)
      forms.length.should == 3
    end

    it "should return two global forms" do
      forms = Form.get_published_investigation_forms(1, 1)
      forms.collect { |form| form.jurisdiction_id.nil? } == 2
    end

    it "should return one jurisdiction specific form" do
      forms = Form.get_published_investigation_forms(1, 1)
      forms.collect { |form| not form.jurisdiction_id.nil? } == 1
    end
  end

end
