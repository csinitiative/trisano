require File.dirname(__FILE__) + '/../../spec_helper'

describe "/value_set_elements/new.rjs" do
  include QuestionsHelper
  
  before(:each) do
    value_element = mock_model(ValueElement)
    value_element.stub!(:name).and_return("Yes")
    value_element.stub!(:should_destroy).and_return("0")
    
    @value_set_element = mock_model(ValueSetElement)
    @value_set_element.stub!(:new_record?).and_return(true)
    @value_set_element.stub!(:form_id).and_return("1")
    @value_set_element.stub!(:name).and_return("MyString")
    @value_set_element.stub!(:parent_element_id).and_return(4)
    @value_set_element.stub!(:value_elements).and_return([value_element])
    
    
    

    assigns[:value_set_element] = @value_set_element
  end

  it "should render new form" do
    render "/value_set_elements/new.rjs"
    
    response.should have_tag("form[action=?][method=post]", value_set_elements_path) do
      with_tag("input#value_set_element_name[name=?]", "value_set_element[name]")
    end
  end
end
