require File.dirname(__FILE__) + '/../../spec_helper'

describe "/form_statuses/new.html.erb" do
  include FormStatusesHelper
  
  before(:each) do
    @form_status = mock_model(FormStatus)
    @form_status.stub!(:new_record?).and_return(true)
    @form_status.stub!(:name).and_return("MyString")
    assigns[:form_status] = @form_status
  end

  it "should render new form" do
    render "/form_statuses/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", form_statuses_path) do
      with_tag("input#form_status_name[name=?]", "form_status[name]")
    end
  end
end


