require File.dirname(__FILE__) + '/../../spec_helper'

describe "/sections/show.html.erb" do
  include SectionsHelper
  
  before(:each) do
    
    form = mock_model(Form)
    form.stub!(:name).and_return("Tummy Ache Demographics")
    
    @section = mock_model(Section)
    @section.stub!(:name).and_return("MyString")
    @section.stub!(:form).and_return(form)

    assigns[:section] = @section
  end

  it "should render attributes in <p>" do
    render "/sections/show.html.haml"
    response.should have_text(/MyString/)
  end
end

