require File.dirname(__FILE__) + '/../../spec_helper'

describe "/forms/builder.html.haml" do
  include FormsHelper
  
  before(:each) do
    @form = mock_model(Form)
    @form.stub!(:name).and_return("MyString")
    @form.stub!(:description).and_return("MyString")

    assigns[:form] = @form
  end

  it "should have the text 'Builder'" do
    render "/forms/builder.html.haml"
    response.should have_text(/Builder/)
  end
end

