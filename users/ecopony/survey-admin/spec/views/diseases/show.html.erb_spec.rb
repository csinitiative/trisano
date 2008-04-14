require File.dirname(__FILE__) + '/../../spec_helper'

describe "/diseases/show.html.erb" do
  include DiseasesHelper
  
  before(:each) do
    @disease = mock_model(Disease)
    @disease.stub!(:name).and_return("MyString")

    assigns[:disease] = @disease
  end

  it "should render attributes in <p>" do
    render "/diseases/show.html.haml"
    response.should have_text(/MyString/)
  end
end

