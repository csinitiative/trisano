require File.dirname(__FILE__) + '/../../spec_helper'

describe "/patients/edit.html.erb" do
  include PatientsHelper
  
  before do
    #TODO: Factor this out and test partial separately
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
      :race => '',
      :ethnicity => ''
    )
    assigns[:patient] = @patient
  end

  it "should render edit form" do
    render "/patients/edit.html.erb"
    
    response.should have_tag("form[action=#{patient_path(@patient)}][method=post]") do
    end
  end
end


