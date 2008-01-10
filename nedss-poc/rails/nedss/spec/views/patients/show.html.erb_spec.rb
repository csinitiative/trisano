require File.dirname(__FILE__) + '/../../spec_helper'

describe "/patients/show.html.erb" do
  include PatientsHelper
  
  before(:each) do
    @patient = mock_model(Patient)

    assigns[:patient] = @patient
  end

  it "should render attributes in <p>" do
    render "/patients/show.html.erb"
  end
end

