require File.dirname(__FILE__) + '/../../spec_helper'

describe "/patients/new.html.erb" do
  include PatientsHelper
  
  before(:each) do
    @patient = mock_model(Patient)
    @patient.stub!(:new_record?).and_return(true)
    assigns[:patient] = @patient
  end

  it "should render new form" do
    render "/patients/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", patients_path) do
    end
  end
end


