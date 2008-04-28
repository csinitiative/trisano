require File.dirname(__FILE__) + '/../../spec_helper'

describe "/forms/edit.html.haml" do
  include FormsHelper
  
  before do
    @form = mock_model(Form)
    @form.stub!(:name).and_return("MyString")
    @form.stub!(:description).and_return("MyString")
    assigns[:form] = @form
  end

  it "should render edit form" do
    render "/forms/edit.html.haml"
    
    response.should have_tag("form[action=#{form_path(@form)}][method=post]") do
      with_tag('input#form_name[name=?]', "form[name]")
      with_tag('input#form_description[name=?]', "form[description]")
    end
  end
end


