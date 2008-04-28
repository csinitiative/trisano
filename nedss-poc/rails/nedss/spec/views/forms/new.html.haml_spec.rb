require File.dirname(__FILE__) + '/../../spec_helper'

describe "/forms/new.html.haml" do
  include FormsHelper
  
  before(:each) do
    @form = mock_model(Form)
    @form.stub!(:new_record?).and_return(true)
    @form.stub!(:name).and_return("MyString")
    @form.stub!(:description).and_return("MyString")
    assigns[:form] = @form
  end

  it "should render new form" do
    render "/forms/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", forms_path) do
      with_tag("input#form_name[name=?]", "form[name]")
      with_tag("input#form_description[name=?]", "form[description]")
    end
  end
end


