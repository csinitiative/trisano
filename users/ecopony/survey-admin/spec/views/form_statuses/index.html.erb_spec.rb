require File.dirname(__FILE__) + '/../../spec_helper'

describe "/form_statuses/index.html.erb" do
  include FormStatusesHelper
  
  before(:each) do
    form_status_98 = mock_model(FormStatus)
    form_status_98.should_receive(:name).and_return("MyString")
    form_status_99 = mock_model(FormStatus)
    form_status_99.should_receive(:name).and_return("MyString")

    assigns[:form_statuses] = [form_status_98, form_status_99]
  end

  it "should render list of form_statuses" do
    render "/form_statuses/index.html.haml"
    response.should have_tag("tr>td", "MyString", 2)
  end
end

