require File.dirname(__FILE__) + '/../../spec_helper'

describe "/patients/index.html.erb" do
  include PatientsHelper
  
  before(:each) do
    patient_98 = mock_model(Patient, :last_name => "Marx", :first_name => "Groucho")
    patient_99 = mock_model(Patient, :last_name => "Silvers", :first_name => "Phil")

    assigns[:patients] = [patient_98, patient_99]
  end

  it "should render list of patients" do
    render "/patients/index.html.erb"
  end

  it "should display first_name last_name in a single element" do
    render "/patients/index.html.erb"
    response.should have_tag('td', 'Groucho Marx')
  end

  it "should have rendered two patients" do
    render "/patients/index.html.erb"
    response.should have_tag('table') do
      with_tag('tr') do
        with_tag('td', 'Groucho Marx')
        with_tag('td', 'Phil Silvers')
      end
    end
  end
end
