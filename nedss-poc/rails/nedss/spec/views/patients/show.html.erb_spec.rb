require File.dirname(__FILE__) + '/../../spec_helper'

describe "/patients/show.html.erb" do
  include PatientsHelper
  
  before(:each) do
    #TODO: Factor out
    @patient = mock_model(Patient,
      :last_name => 'Marx',
      :first_name => 'Groucho',
      :street_address => '',
      :date_of_birth => '',
      :city => '',
      :phone_1 => '',
      :county => '',
      :state => '',
      :zip_code => '',
      :country => '',
      :sex => '',
      :race_id => '',
      :ethnicity_id => '',
      :language_id => ''
    )

    assigns[:patient] = @patient
  end

  it "should render attributes" do
    render "/patients/show.html.erb"
  end
end

