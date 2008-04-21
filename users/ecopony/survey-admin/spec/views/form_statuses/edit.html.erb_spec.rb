require File.dirname(__FILE__) + '/../../spec_helper'

describe "/form_statuses/edit.html.erb" do
  include FormStatusesHelper
  
  before do
    @form_status = mock_model(FormStatus)
    @form_status.stub!(:name).and_return("MyString")
    assigns[:form_status] = @form_status
  end

  it "should render edit form" do
    render "/form_statuses/edit.html.haml"
    
    response.should have_tag("form[action=#{form_status_path(@form_status)}][method=post]") do
      with_tag('input#form_status_name[name=?]', "form_status[name]")
    end
  end
end


