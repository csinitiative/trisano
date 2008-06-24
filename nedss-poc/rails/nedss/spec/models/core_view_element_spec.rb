require File.dirname(__FILE__) + '/../spec_helper'

describe CoreViewElement do
  before(:each) do
    @core_view_element = CoreViewElement.new
    @core_view_element.name = "demographics"
  end

  it "should be valid" do
    @core_view_element.should be_valid
  end
  
  describe "when determining available core views" do
    
    it "should return nil if no parent_element_id is set on the core view element" do
      @core_view_element.available_core_views.should be_nil
    end
    
    it "should return all core view names when none are in use" do
      form = Form.new
      form.save_and_initialize_form_elements
      @core_view_element.parent_element_id = form.form_base_element.id
      available_core_views = @core_view_element.available_core_views
      available_core_views.size.should == 7
      available_core_views.flatten.uniq.include?("Demographics").should be_true
      available_core_views.flatten.uniq.include?("Clinical").should be_true
      available_core_views.flatten.uniq.include?("Laboratory").should be_true
      available_core_views.flatten.uniq.include?("Contacts").should be_true
      available_core_views.flatten.uniq.include?("Epidemiological").should be_true
      available_core_views.flatten.uniq.include?("Reporting").should be_true
      available_core_views.flatten.uniq.include?("Administrative").should be_true
    end
    
    it "should return only available core view names when some are in use" do
      form = Form.new
      form.save_and_initialize_form_elements
      base_element_id = form.form_base_element.id
     
      demographic_core_config = CoreViewElement.new(:parent_element_id => base_element_id, :name => "Demographics")
      clinical_core_config = CoreViewElement.new(:parent_element_id => base_element_id, :name => "Clinical")
      demographic_core_config.save_and_add_to_form
      clinical_core_config.save_and_add_to_form
       
      @core_view_element.parent_element_id = base_element_id
      available_core_views = @core_view_element.available_core_views
      available_core_views.size.should == 5
      available_core_views.flatten.uniq.include?("Demographics").should be_false
      available_core_views.flatten.uniq.include?("Clinical").should be_false
      available_core_views.flatten.uniq.include?("Laboratory").should be_true
      available_core_views.flatten.uniq.include?("Contacts").should be_true
      available_core_views.flatten.uniq.include?("Epidemiological").should be_true
      available_core_views.flatten.uniq.include?("Reporting").should be_true
      available_core_views.flatten.uniq.include?("Administrative").should be_true
    end
    
  end
  
  describe "when created with 'save and add to form'" do
    
    it "should be a child of the form's base" do
      form = Form.new
      form.save_and_initialize_form_elements
      @core_view_element.parent_element_id = form.form_base_element.id
      @core_view_element.save_and_add_to_form
      @core_view_element.parent_id.should_not be_nil
      form.form_base_element.children[1].id.should == @core_view_element.id
    end
    
    it "should receive a tree id" do
      form = Form.new
      form.save_and_initialize_form_elements
      @core_view_element.parent_element_id = form.form_base_element.id
      @core_view_element.save_and_add_to_form
      @core_view_element.tree_id.should_not be_nil
      @core_view_element.tree_id.should eql(form.form_base_element.tree_id)
    end
    
  end

end