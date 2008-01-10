require File.dirname(__FILE__) + '/../../spec_helper'

describe "/ethnicities/index.html.erb" do
  include EthnicitiesHelper
  
  before(:each) do
    ethnicity_98 = mock_model(Ethnicity)
    ethnicity_99 = mock_model(Ethnicity)

    assigns[:ethnicities] = [ethnicity_98, ethnicity_99]
  end

  it "should render list of ethnicities" do
    render "/ethnicities/index.html.erb"
  end
end

