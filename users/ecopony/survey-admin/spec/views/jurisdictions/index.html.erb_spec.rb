require File.dirname(__FILE__) + '/../../spec_helper'

describe "/jurisdictions/index.html.erb" do
  include JurisdictionsHelper
  
  before(:each) do
    jurisdiction_98 = mock_model(Jurisdiction)
    jurisdiction_98.should_receive(:name).and_return("MyString")
    jurisdiction_99 = mock_model(Jurisdiction)
    jurisdiction_99.should_receive(:name).and_return("MyString")

    assigns[:jurisdictions] = [jurisdiction_98, jurisdiction_99]
  end

  it "should render list of jurisdictions" do
    render "/jurisdictions/index.html.haml"
    response.should have_tag("tr>td", "MyString", 2)
  end
end

