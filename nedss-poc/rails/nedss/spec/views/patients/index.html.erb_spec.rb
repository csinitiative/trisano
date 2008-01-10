require File.dirname(__FILE__) + '/../../spec_helper'

describe "/patients/index.html.erb" do
  include PatientsHelper
  
  before(:each) do
    patient_98 = mock_model(Patient)
    patient_99 = mock_model(Patient)

    assigns[:patients] = [patient_98, patient_99]
  end

  it "should render list of patients" do
    render "/patients/index.html.erb"
  end
end

