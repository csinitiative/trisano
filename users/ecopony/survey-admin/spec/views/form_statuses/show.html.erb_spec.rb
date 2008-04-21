require File.dirname(__FILE__) + '/../../spec_helper'

describe "/form_statuses/show.html.erb" do
  include FormStatusesHelper
  
  before(:each) do
    @form_status = mock_model(FormStatus)
    @form_status.stub!(:name).and_return("MyString")

    assigns[:form_status] = @form_status
  end

  it "should render attributes in <p>" do
    render "/form_statuses/show.html.haml"
    response.should have_text(/MyString/)
  end
end

