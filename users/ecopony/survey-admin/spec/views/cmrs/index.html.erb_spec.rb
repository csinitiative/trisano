require File.dirname(__FILE__) + '/../../spec_helper'

describe "/cmrs/index.html.erb" do
  include CmrsHelper
  
  before(:each) do
    cmr_98 = mock_model(Cmr)
    cmr_98.should_receive(:name).and_return("MyString")
    # cmr_98.should_receive(:disease_id).and_return("1")
    # cmr_98.should_receive(:jurisdiction_id).and_return("1")
    cmr_99 = mock_model(Cmr)
    cmr_99.should_receive(:name).and_return("MyString")
    # cmr_99.should_receive(:disease_id).and_return("1")
    # cmr_99.should_receive(:jurisdiction_id).and_return("1")

    assigns[:cmrs] = [cmr_98, cmr_99]
  end

  it "should render list of cmrs" do
    render "/cmrs/index.html.haml"
    response.should have_tag("tr>td", "MyString", 2)
  end
end

