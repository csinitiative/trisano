require File.dirname(__FILE__) + '/../../spec_helper'

describe "/cmrs/show.html.erb" do
  include CmrsHelper
  
  before(:each) do
    @cmr = mock_model(Cmr)
    @cmr.stub!(:name).and_return("MyString")
    @cmr.stub!(:disease_id).and_return("1")
    @cmr.stub!(:jurisdiction_id).and_return("1")

    assigns[:cmr] = @cmr
  end

  it "should render attributes in <p>" do
    render "/cmrs/show.html.haml"
    response.should have_text(/MyString/)
  end
end

