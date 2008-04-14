require File.dirname(__FILE__) + '/../../spec_helper'

describe "/jurisdictions/show.html.erb" do
  include JurisdictionsHelper
  
  before(:each) do
    @jurisdiction = mock_model(Jurisdiction)
    @jurisdiction.stub!(:name).and_return("MyString")

    assigns[:jurisdiction] = @jurisdiction
  end

  it "should render attributes in <p>" do
    render "/jurisdictions/show.html.haml"
    response.should have_text(/MyString/)
  end
end

