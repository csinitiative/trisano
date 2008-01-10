require File.dirname(__FILE__) + '/../../spec_helper'

describe "/patients/edit.html.erb" do
  include PatientsHelper
  
  before do
    @patient = mock_model(Patient)
    assigns[:patient] = @patient
  end

  it "should render edit form" do
    render "/patients/edit.html.erb"
    
    response.should have_tag("form[action=#{patient_path(@patient)}][method=post]") do
    end
  end
end


