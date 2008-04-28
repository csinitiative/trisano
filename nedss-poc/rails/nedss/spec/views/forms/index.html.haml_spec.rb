require File.dirname(__FILE__) + '/../../spec_helper'

describe "/forms/index.html.haml" do
  include FormsHelper
  
  before(:each) do
    form_98 = mock_model(Form)
    form_98.should_receive(:name).and_return("MyString")
    form_99 = mock_model(Form)
    form_99.should_receive(:name).and_return("MyString")

    assigns[:forms] = [form_98, form_99]
  end

  it "should render list of forms" do
    render "/forms/index.html.haml"
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
  end
end
