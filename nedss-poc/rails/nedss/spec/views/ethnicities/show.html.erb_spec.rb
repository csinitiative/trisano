require File.dirname(__FILE__) + '/../../spec_helper'

describe "/ethnicities/show.html.erb" do
  include EthnicitiesHelper
  
  before(:each) do
    @ethnicity = mock_model(Ethnicity)

    assigns[:ethnicity] = @ethnicity
  end

  it "should render attributes in <p>" do
    render "/ethnicities/show.html.erb"
  end
end

