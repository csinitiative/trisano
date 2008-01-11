require File.dirname(__FILE__) + '/../../spec_helper'

describe "/patients/new.html.erb" do
  include PatientsHelper
  
  before(:each) do
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
    @patient.stub!(:new_record?).and_return(true)
    assigns[:patient] = @patient
  end

  it "should render new form" do
    render "/patients/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", patients_path) do
    end
  end
end
