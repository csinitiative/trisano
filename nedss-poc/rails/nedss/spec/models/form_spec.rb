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
    end
    
  end
  
  
end
