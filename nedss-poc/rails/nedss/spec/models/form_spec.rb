require File.dirname(__FILE__) + '/../spec_helper'

describe Form do
  before(:each) do
    @form = Form.new
  end

  it "should be valid" do
    @form.should be_valid
  end
  
  describe "when created" do
    
    it "should bootstrap the form element hierarchy" do
      @form.save!
      form_base_element = @form.form_base_element
      form_base_element.should_not be_nil
      default_view_element = form_base_element.children[0]
      default_view_element.should_not be_nil
      default_view_element.name.should == "Default View"
      default_section_element = default_view_element.children[0]
      default_section_element.should_not be_nil
      default_section_element.name.should == "Default Section"
    end
    
  end
  
  describe "the get_investigation_forms class method" do
    fixtures :forms

    it "should return three forms" do
      forms = Form.get_investigation_forms(1, 1)
      forms.length.should == 3
    end

    it "should return two global forms" do
      forms = Form.get_investigation_forms(1, 1)
      forms.collect { |form| form.jurisdiction_id.nil? } == 2
    end

    it "should return one jurisdiction specific form" do
      forms = Form.get_investigation_forms(1, 1)
      forms.collect { |form| not form.jurisdiction_id.nil? } == 1
    end
  end

end
