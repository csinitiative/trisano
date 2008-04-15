require File.dirname(__FILE__) + '/../../spec_helper'

describe "/forms/edit.html.erb" do
  include FormsHelper
  
  before do
    
    group = mock_model(Group)
    group.stub!(:name).and_return("Standard Demographics")
    
    section = mock_model(Section)
    section.stub!(:name).and_return("Tummy Ache Demographics")
    section.stub!(:groups).and_return([group])
    
    @form = mock_model(Form)
    @form.stub!(:name).and_return("MyString")
    @form.stub!(:description).and_return("MyString")
    @form.stub!(:jurisdiction_id).and_return("1")
    @form.stub!(:disease_id).and_return("1")
    @form.stub!(:status).and_return("1")
    @form.stub!(:sections).and_return([section])
    assigns[:form] = @form
  end

  it "should render edit form" do
    render "/forms/edit.html.haml"
    
    response.should have_tag("form[action=#{form_path(@form)}][method=post]") do
      with_tag('input#form_name[name=?]', "form[name]")
      with_tag('input#form_description[name=?]', "form[description]")
      # with_tag('input#form_status[name=?]', "form[status]")
    end
  end
end


