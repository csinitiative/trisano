require File.dirname(__FILE__) + '/../../spec_helper'

describe "/forms/show.html.haml" do
  include FormsHelper
  
  before(:each) do
    @form = mock_model(Form)
    @form.stub!(:name).and_return("MyString")
    @form.stub!(:description).and_return("MyString")

    assigns[:form] = @form
  end

  it "should render attributes in <p>" do
    render "/forms/show.html.haml"
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
  end
end

